-- Code annotations.
--
-- data_dir is left at haunt's default (stdpath("data") .. "/haunt/"). It was
-- previously pinned into the notes vault via productivity.notes, which resolved
-- to ~/Documents/Notes — a directory that did not exist, while the real vault
-- was $LOCI_OBSIDIAN_VAULT. Annotations are code metadata, not notes, so they
-- belong in the data dir; haunt already scopes them per repository and, with
-- per_branch_bookmarks, per branch. That also retires the DirChanged hook that
-- existed only to re-point data_dir on every `:cd`.
require("haunt").setup({
  per_branch_bookmarks = true,
  picker = "snacks",
})
