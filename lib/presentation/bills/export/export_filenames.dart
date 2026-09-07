/// Shared export filename rules (M2/F7.4): `bagistruk-<slug>-<billId8>.<ext>`.
/// The bill-id suffix keeps filenames unique when two bills share a slug
/// (`Bukber!!!` vs `Bukber`), the title is emoji-only, or the title is empty
/// (falls back to `bagistruk-bill`). Used identically by CSV, PDF, and XLSX
/// so all three formats sort together and never collide.
class ExportFilenames {
  const ExportFilenames._();

  static String slug(String title) {
    final cleaned = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'bagistruk-bill' : 'bagistruk-$cleaned';
  }

  static String unique(String title, String billId, String ext) {
    final shortId = billId.length >= 8 ? billId.substring(0, 8) : billId;
    return '${slug(title)}-$shortId.$ext';
  }
}
