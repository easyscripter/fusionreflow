//! Zip access with limits: entry lookup (exact, then case-insensitive) and
//! bounded reads, so a hostile archive cannot exhaust memory.
use crate::import::ReadSeek;
use std::collections::HashMap;
use std::io::Read;
use zip::ZipArchive;

/// Most entries an archive may hold.
pub(super) const MAX_ENTRIES: usize = 10_000;
/// Most bytes one entry may unpack to.
pub(super) const MAX_ENTRY_BYTES: u64 = 64 * 1024 * 1024;
/// Most bytes an import may unpack in total.
pub(super) const MAX_TOTAL_BYTES: u64 = 512 * 1024 * 1024;

/// Size limits; [`Limits::DEFAULT`] outside of tests.
#[derive(Clone, Copy)]
pub(super) struct Limits {
    pub entries: usize,
    pub entry: u64,
    pub total: u64,
}

impl Limits {
    pub const DEFAULT: Self = Self {
        entries: MAX_ENTRIES,
        entry: MAX_ENTRY_BYTES,
        total: MAX_TOTAL_BYTES,
    };
}

/// Why an archive operation failed.
#[derive(Debug, PartialEq, Eq)]
pub(super) enum ArchiveError {
    NotZip(String),
    TooManyEntries,
    Missing,
    EntryTooLarge,
    TotalTooLarge,
    Damaged(String),
}

pub(super) struct Archive<'a> {
    zip: ZipArchive<&'a mut dyn ReadSeek>,
    names: Vec<String>,
    exact: HashMap<String, usize>,
    lower: HashMap<String, usize>,
    total: u64,
    limits: Limits,
}

impl<'a> Archive<'a> {
    pub fn open(src: &'a mut dyn ReadSeek, limits: Limits) -> Result<Self, ArchiveError> {
        let mut zip = ZipArchive::new(src).map_err(|e| ArchiveError::NotZip(e.to_string()))?;
        if zip.len() > limits.entries {
            return Err(ArchiveError::TooManyEntries);
        }
        let mut names = Vec::with_capacity(zip.len());
        let mut exact = HashMap::new();
        let mut lower = HashMap::new();
        for i in 0..zip.len() {
            let f = zip
                .by_index_raw(i)
                .map_err(|e| ArchiveError::Damaged(e.to_string()))?;
            let name = f
                .name()
                .map_or_else(|_| String::new(), |n| n.trim_start_matches('/').to_owned());
            if !f.is_dir() {
                exact.entry(name.clone()).or_insert(i);
                lower.entry(name.to_lowercase()).or_insert(i);
            }
            names.push(name);
        }
        Ok(Self {
            zip,
            names,
            exact,
            lower,
            total: 0,
            limits,
        })
    }

    fn index(&self, path: &str) -> Option<usize> {
        self.exact
            .get(path)
            .or_else(|| self.lower.get(&path.to_lowercase()))
            .copied()
    }

    /// The real entry name for `path` (exact match first, then ignoring case).
    pub fn canonical(&self, path: &str) -> Option<&str> {
        self.index(path)
            .and_then(|i| self.names.get(i))
            .map(String::as_str)
    }

    /// Reads an entry fully, within the per-entry and total limits.
    pub fn read(&mut self, path: &str) -> Result<Vec<u8>, ArchiveError> {
        let i = self.index(path).ok_or(ArchiveError::Missing)?;
        let file = self
            .zip
            .by_index(i)
            .map_err(|e| ArchiveError::Damaged(e.to_string()))?;
        if file.size() > self.limits.entry {
            return Err(ArchiveError::EntryTooLarge);
        }
        // The header may lie about the size: cap the read itself too.
        let mut buf = Vec::new();
        file.take(self.limits.entry.saturating_add(1))
            .read_to_end(&mut buf)
            .map_err(|e| ArchiveError::Damaged(e.to_string()))?;
        let len = u64::try_from(buf.len()).unwrap_or(u64::MAX);
        if len > self.limits.entry {
            return Err(ArchiveError::EntryTooLarge);
        }
        self.total = self.total.saturating_add(len);
        if self.total > self.limits.total {
            return Err(ArchiveError::TotalTooLarge);
        }
        Ok(buf)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{Cursor, Write};
    use zip::write::SimpleFileOptions;

    fn zip_of(files: &[(&str, &[u8])]) -> Cursor<Vec<u8>> {
        let mut z = zip::ZipWriter::new(Cursor::new(Vec::new()));
        for (n, d) in files {
            z.start_file(*n, SimpleFileOptions::default())
                .expect("start");
            z.write_all(d).expect("write");
        }
        Cursor::new(z.finish().expect("finish").into_inner())
    }

    const TINY: Limits = Limits {
        entries: 3,
        entry: 10,
        total: 15,
    };

    #[test]
    fn finds_exact_then_case_insensitive() {
        let mut src = zip_of(&[("A/b.txt", b"x"), ("a/b.txt", b"y")]);
        let mut a = Archive::open(&mut src, Limits::DEFAULT).expect("open");
        assert_eq!(a.canonical("a/b.txt"), Some("a/b.txt"));
        assert_eq!(a.canonical("A/B.TXT"), Some("A/b.txt"));
        assert_eq!(a.read("a/b.txt").expect("read"), b"y");
        assert_eq!(a.read("none"), Err(ArchiveError::Missing));
    }

    #[test]
    fn limits_are_enforced() {
        let mut src = zip_of(&[("a", b"01234567890"), ("b", b"012345678")]);
        let mut a = Archive::open(&mut src, TINY).expect("open");
        assert_eq!(a.read("a"), Err(ArchiveError::EntryTooLarge));
        assert!(a.read("b").is_ok());
        assert_eq!(a.read("b"), Err(ArchiveError::TotalTooLarge));
        let mut many = zip_of(&[("1", b""), ("2", b""), ("3", b""), ("4", b"")]);
        assert!(matches!(
            Archive::open(&mut many, TINY),
            Err(ArchiveError::TooManyEntries)
        ));
    }

    #[test]
    fn not_a_zip() {
        let mut src = Cursor::new(b"nope".to_vec());
        assert!(matches!(
            Archive::open(&mut src, Limits::DEFAULT),
            Err(ArchiveError::NotZip(_))
        ));
    }

    #[test]
    fn lying_header_cannot_smuggle_more_than_the_limit() {
        let mut bytes = zip_of(&[("a", &[b'x'; 5000])]).into_inner();
        // Central directory entry: signature 0x02014b50, uncompressed size at +24.
        let pos = bytes
            .windows(4)
            .position(|w| w == [0x50, 0x4b, 0x01, 0x02])
            .expect("central header");
        bytes[pos + 24..pos + 28].copy_from_slice(&1u32.to_le_bytes());
        let mut src = Cursor::new(bytes);
        let mut a = Archive::open(
            &mut src,
            Limits {
                entries: 10,
                entry: 100,
                total: 1000,
            },
        )
        .expect("open");
        match a.read("a") {
            Ok(data) => assert!(data.len() <= 100, "read {} bytes", data.len()),
            Err(e) => assert!(matches!(
                e,
                ArchiveError::EntryTooLarge | ArchiveError::Damaged(_)
            )),
        }
    }
}
