# Sorani voice review — 0.2

The user described the new female Sorani voice as “Better, but pronunciation needs work.” They identified ئاو as incorrect in the first sample and selected revision B from A/B/C. Revision B is the included water recording; its model input is `aw .` and it uses 48 inference steps.

All 500 translations remain draft. Only the water revision has individual user pronunciation approval. The other 499 words need fluent listening review; machine generation does not establish their accuracy.

Native recordings can override each built-in WAV using `recordings/ckb/<word_id>.wav`. This also supports a future full human-recorded voice pack without rebuilding the executable.

CSV update: 10 written Sorani translations were corrected by the user and marked reviewed. Their matching audio was regenerated; the new pronunciations still need user listening review. The approved water recording is unchanged.
