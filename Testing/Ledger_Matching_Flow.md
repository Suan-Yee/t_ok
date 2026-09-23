# Ledger Matching Flow For New Member

## 1) What this process does
This process decides, for each UPDATE row:
1. Which ledger project name is the best match.
2. Whether the row is normal, yellow, or red.
3. Whether company columns should be filled.
4. What note should be written in the remark column.

If no safe match is found, the process does not fill company columns.

---

## 2) Input and output
Input source:
1. UPDATE sheet column H (feature name).
2. Ledger workbook WB4実施管理.xlsm, sheet WB4実施管理.

Output target on UPDATE sheet:
1. H column: normal, yellow, or red result.
2. K-AA columns: company deploy marks.
3. AB column: sync value.
4. AO column: remark text (candidate info when needed).

Execution buttons (current behavior):
1. First button (リストにする / `Create_SVNLOG_LIST_EXE_Start`):
   1. Runs input parse/filter/matching.
   2. Builds `UPDATEモジュール一覧【株式】`.
   3. Does NOT write to 棚卸しファイル.
2. Second button (line C17 / `Create_INVENTORY_EXPORT_EXE_Start`):
   1. Reads source path from 入力!C21.
   2. Copies source file into `棚卸しファイル` folder under this workbook path.
   3. Writes data from `UPDATEモジュール一覧【株式】` into the copied file.

---

## 3) Before matching (preprocessing)
Before compare, both names are normalized.

Main normalization:
1. Remove leading symbols (example: ■).
2. Remove PBxxxxxxxx_ prefix if present.
3. Remove trailing _結合テスト完了 if present.
4. Convert separators (space, middle dot, hyphen) to underscore.
5. Remove unnecessary brackets around names.
6. Compress repeated underscores and trim edge underscores.
7. Compare in uppercase form.

Also, leading company marker is extracted if present.
Examples: (44), 0D_, 内藤証券_, 【共同1】.

The matching identity is:
1. company marker
2. normalized name

So same name with different marker is treated as different identity.

---

## 4) Exact runtime order (first to last)
For one UPDATE row, matching always follows this order:

Step 1:
1. Build normalized query name.
2. Extract marker.

Step 2: Tier 1 (exact + same marker)
1. If exact one candidate, stop as EXACT_SINGLE.
2. If exact multiple rows, stop as EXACT_MULTI.
3. If not found, go Tier 2.

Step 3: Tier 2 (exact shared or no-marker path)
1. If exact one candidate, stop as EXACT_SINGLE.
2. If exact multiple candidates, stop as EXACT_MULTI.
3. If not found, go Tier 3.

Step 4: Tier 3 (family match, QUERY -> QUERY_suffix)
1. If one candidate, stop as UNIQUE_SINGLE.
2. If multiple candidates, stop as UNIQUE_MULTI.
3. If no candidate, go Tier 4.

Step 5: Tier 4 (fuzzy)
1. Score candidates by Dice.
2. Use Levenshtein only as helper for tie ranking.
3. Accept only when:
   1. best Dice >= 0.85
   2. best - second >= 0.05
4. If accepted, stop as FUZZY_SINGLE.
5. If not accepted, go Tier 5.

Step 6: Tier 5 (one-character near)
1. Check one-edit-away candidates (insert/delete/replace one char).
2. If found, stop as ONE_EDIT_NEAR.
3. If not found, stop as NO_MATCH.

Stop rule:
1. First tier that returns final status ends matching for that row.
2. Only fuzzy failure continues by design (Tier 4 -> Tier 5).

### Confirmation of stop behavior
1. Matching runs in order from Step 1 to Step 6.
2. If a step returns final status, later steps are not executed.
3. If a step does not return final status, matching continues to next step.

### Trace case A (same project name, fail Step 1-5, match at Step 6)
Use one SVN project name:
1. UPDATE H:
   1. PB99500001_(44)入出金制御A_結合テスト完了

Prepare ledger so this row walks to Step 6:
1. Step 2 fail (no exact same-marker):
   1. Do not register (44)入出金制御A
2. Step 3 fail (no shared/unmarked exact):
   1. Do not register unmarked 入出金制御A
3. Step 4 fail (no family QUERY_suffix):
   1. Do not register (44)入出金制御A_オンライン, etc.
4. Step 5 fail (fuzzy not accepted):
   1. Register candidates that are not strong enough for fuzzy accept
   2. Example: (44)入出金処理A, (44)入出金画面A (low score or low margin)
5. Step 6 match (one-edit near exists):
   1. Register (44)入出金制御B

Expected result:
1. Final status = ONE_EDIT_NEAR
2. H yellow
3. K-AA blank, AB blank
4. AO contains Ledger候補 note

### Trace case B (same style test, match at Step 4)
Use one SVN project name:
1. UPDATE H:
   1. PB99600001_(44)NISA残高表示_結合テスト完了

Prepare ledger so this row stops at Step 4:
1. Step 2 fail:
   1. Do not register (44)NISA残高表示 exact row
2. Step 3 fail:
   1. Do not register unmarked NISA残高表示 exact row
3. Step 4 success:
   1. Register exactly one family candidate
   2. Example: (44)NISA残高表示_オンライン

Expected result:
1. Final status = UNIQUE_SINGLE
2. H yellow
3. K-AA filled, AB filled
4. AO contains Ledger候補 note
5. Steps 5 and 6 are not executed for this row

### Test-ready examples for each step (full names)

Step 1 test (normalization + marker extraction):
1. SVN sample A:
   1. PB90000001_(44)口座開設API改善_結合テスト完了
   2. Expected marker: 44
   3. Expected normalized name: 口座開設API改善
2. SVN sample B:
   1. PB90000002_【共同1】電話認証導入対応_結合テスト完了
   2. Expected marker: 90
   3. Expected normalized name: 電話認証導入対応

Step 2 test (Tier 1 exact + same marker):
1. SVN input:
   1. PB91000001_(44)取引管理番号初期化_結合テスト完了
2. Ledger alternatives:
   1. Case A (single):
      1. (44)取引管理番号初期化 (1 row only)
      2. Expected: EXACT_SINGLE
   2. Case B (duplicate):
      1. (44)取引管理番号初期化 appears in 2 rows
      2. Expected: EXACT_MULTI

Step 3 test (Tier 2 exact shared/no-marker path):
1. SVN input:
   1. PB92000001_(44)共通帳票改善_結合テスト完了
2. Ledger alternatives:
   1. Case A (unmarked single):
      1. 共通帳票改善 (no leading marker, 1 row)
      2. Expected: EXACT_SINGLE
   2. Case B (unmarked duplicate):
      1. 共通帳票改善 (no leading marker, 2 rows)
      2. Expected: EXACT_MULTI

Step 4 test (Tier 3 family match QUERY -> QUERY_suffix):
1. SVN input:
   1. PB93000001_(44)NISA残高表示_結合テスト完了
2. Ledger alternatives:
   1. Case A (single family):
      1. (44)NISA残高表示_オンライン
      2. Expected: UNIQUE_SINGLE
   2. Case B (multi family):
      1. (44)NISA残高表示_オンライン
      2. (44)NISA残高表示_画面開放
      3. Expected: UNIQUE_MULTI

Step 5 test (Tier 4 fuzzy):
1. SVN input:
   1. PB94000001_(44)配信制御改善_結合テスト完了
2. Ledger alternatives:
   1. Case A (clear best):
      1. (44)配信制御改修
      2. Second-best is far enough (margin >= 0.05)
      3. Expected: FUZZY_SINGLE
   2. Case B (near tie):
      1. (44)配信制御改修
      2. (44)配信制御画面改善
      3. Best score may fail margin rule
      4. Expected: continue to Step 6
   3. Case C (fuzzy match but duplicate ledger rows):
      1. (44)配信制御改修 appears in 2 ledger rows, margin still passes
      2. Expected: status becomes EXACT_MULTI, not FUZZY_SINGLE (the code reuses the EXACT_MULTI status whenever the matched key itself has more than one ledger row, even when it was found via fuzzy scoring)

Step 2b test (Tier 1 alias-equivalent marker exact match) ? NEW:
1. SVN input:
   1. PB99600001_(44)NISA残高表示_結合テスト完了
2. Ledger alternatives:
   1. Case A (alias-equivalent single):
      1. (91)NISA残高表示 (1 row only, no (44) row exists)
      2. Expected: EXACT_SINGLE (accepted because 44 and 91 are alias-equivalent)
   2. Case B (alias-equivalent duplicate):
      1. (91)NISA残高表示 appears in 2 rows
      2. Expected: EXACT_MULTI
   3. Case C (marker not aliased, must fall through):
      1. (90)NISA残高表示
      2. Expected: Step 2 does not match (44 and 90 are not in the same alias group), matching continues to Step 3
3. Same check applies to every configured pair, not only 44/91, for example:
   1. SVN input: PB99700001_(92)電話認証_結合テスト完了 / Ledger: (0F)電話認証 -> EXACT_SINGLE (92 <-> 0F)
   2. SVN input: PB99800001_(93)入金確認_結合テスト完了 / Ledger: (0X)入金確認 -> EXACT_SINGLE (93 <-> 0X)
   3. SVN input: PB99900001_(94)出金確認_結合テスト完了 / Ledger: (46)出金確認 -> EXACT_SINGLE (94 <-> 46)

Step 6 test (Tier 5 one-edit near):
1. SVN input:
   1. PB95000001_(44)入出金制御A_結合テスト完了
2. Ledger alternatives:
   1. Case A (one-edit exists):
      1. (44)入出金制御B
      2. Expected: ONE_EDIT_NEAR
   2. Case B (none exists):
      1. No one-edit candidate survives guard rules
      2. Expected: NO_MATCH

How to prepare quick ledger test data for one SVN input:
1. Put one SVN row in UPDATE H using one sample above.
2. In ledger, register only the Case A candidate rows first and run.
3. Then replace with Case B candidate rows and run again.
4. Compare H color + K-AA/AB + AO with expected status.

### Why condition is not met and why it proceeds to next step

Step 2 not met -> proceed to Step 3 (Tier 1 exact + same marker):
1. SVN input:
   1. PB99600001_(44)NISA残高表示_結合テスト完了
2. Ledger rows:
   1. (90)NISA残高表示
3. Why Step 2 is not met:
   1. Name is exact, but marker is different (44 vs 90).
   2. Tier 1 requires exact + same marker, so this row is rejected in Tier 1.
4. Why proceed:
   1. Tier 1 returns no final candidate, so runtime moves to Tier 2.

Important for this step (updated):
1. ENV_ALIAS (example: 44 <-> 91) IS applied inside Tier 1 (Step 2): if the literal same-marker exact check fails, the code re-checks the same exact-name candidates using alias-equivalent markers (both directions) before moving on to Step 3. See "Alias-aware matching and deploy expansion" below.
2. ENV_ALIAS is NOT used for marker comparison in Tier 2 (shared/no-marker exact), Tier 3 (family), Tier 4 (fuzzy), or Tier 5 (one-edit) ? those tiers only accept a literal same marker or a blank marker on either side.
3. ENV_ALIAS is also applied when building the deploy code set from `本実施環境`, so marking one alias side also marks the other.

Step 3 not met -> proceed to Step 4 (Tier 2 exact shared/no-marker path):
1. SVN input:
   1. PB99600001_(44)NISA残高表示_結合テスト完了
2. Ledger rows:
   1. (44)NISA残高表示_オンライン
3. Why Step 3 is not met:
   1. Tier 2 still needs exact normalized name (NISA残高表示).
   2. Ledger has only suffix form (NISA残高表示_オンライン), so exact condition fails.
4. Why proceed:
   1. Tier 2 returns no exact candidate, so runtime moves to Tier 3 (family match).

Step 4 not met -> proceed to Step 5 (Tier 3 family QUERY -> QUERY_suffix):
1. SVN input:
   1. PB94000001_(44)配信制御改善_結合テスト完了
2. Ledger rows:
   1. (44)配信制御改修
   2. (44)配信管理改善
3. Why Step 4 is not met:
   1. Tier 3 requires family form where candidate starts with QUERY_.
   2. QUERY is 配信制御改善, but no candidate begins with 配信制御改善_.
4. Why proceed:
   1. Tier 3 returns no family candidate, so runtime moves to Tier 4 (fuzzy).

Step 5 not met -> proceed to Step 6 (Tier 4 fuzzy):
1. SVN input:
   1. PB94000001_(44)配信制御改善_結合テスト完了
2. Ledger rows:
   1. (44)配信制御改修
   2. (44)配信制御画面改善
3. Why Step 5 is not met:
   1. Best candidate may pass 0.85, but margin to second is too small.
   2. Tier 4 acceptance requires both best >= 0.85 and (best - second) >= 0.05.
4. Why proceed:
   1. Tier 4 fuzzy returns not accepted, and this is the designed handoff to Tier 5.

---

## 5) Guard rules applied during candidate filtering
Candidate can be rejected before final decision by these guards:

1. Number conflict guard:
- mismatch in labels like 要件, フェーズ, PH means not same project.

2. Stem guard:
- generic shorter name cannot steal a more specific long query.

3. Marker safety:
- different marker candidates are blocked in marker-aware paths.

---

## 6) Final status and what user sees
EXACT_SINGLE:
1. H normal.
2. Fill K-AA and AB.
3. AO no forced remark.

EXACT_MULTI:
1. H yellow.
2. Do not fill K-AA, AB.
3. AO add Ledger候補 note.

UNIQUE_SINGLE:
1. H yellow.
2. Fill K-AA and AB.
3. AO add Ledger候補 note.

UNIQUE_MULTI:
1. H yellow.
2. Do not fill K-AA, AB.
3. AO add Ledger候補 note.

FUZZY_SINGLE:
1. H normal.
2. Fill K-AA and AB.
3. AO usually no forced remark.

ONE_EDIT_NEAR:
1. H yellow.
2. Do not fill K-AA, AB.
3. AO add Ledger候補 note.

NO_MATCH:
1. H red text.
2. Do not fill K-AA, AB.
3. AO can remain existing memo, with optional hint if available.

### Examples for each status

EXACT_SINGLE example:
1. UPDATE H: PB12345678_(44)口座開設API改善_結合テスト完了
2. Ledger: (44)口座開設API改善
3. Result:
   1. status = EXACT_SINGLE
   2. H normal
   3. K-AA filled, AB filled
   4. AO no required candidate note

EXACT_MULTI example:
1. UPDATE H: PB12345678_(44)取引管理番号初期化_結合テスト完了
2. Ledger: same identity appears in two ledger rows (duplicate)
3. Result:
   1. status = EXACT_MULTI
   2. H yellow
   3. K-AA blank, AB blank
   4. AO contains Ledger候補 with duplicate hint

UNIQUE_SINGLE example:
1. UPDATE H: PB12345678_(44)NISA残高表示_結合テスト完了
2. Ledger exact name not found, but one family candidate exists:
   1. (44)NISA残高表示_オンライン
3. Result:
   1. status = UNIQUE_SINGLE
   2. H yellow
   3. K-AA filled, AB filled
   4. AO contains Ledger候補 note

UNIQUE_MULTI example:
1. UPDATE H: PB12345678_(44)NISA残高表示_結合テスト完了
2. Ledger family candidates are multiple:
   1. (44)NISA残高表示_オンライン
   2. (44)NISA残高表示_画面開放
3. Result:
   1. status = UNIQUE_MULTI
   2. H yellow
   3. K-AA blank, AB blank
   4. AO contains Ledger候補 list

FUZZY_SINGLE example:
1. UPDATE H: PB12345678_(44)配信制御改善_結合テスト完了
2. Ledger nearest candidate:
   1. (44)配信制御改修
3. Dice passes threshold and margin (best >= 0.85 and gap >= 0.05)
4. Result:
   1. status = FUZZY_SINGLE
   2. H normal
   3. K-AA filled, AB filled

ONE_EDIT_NEAR example:
1. UPDATE H: PB12345678_(44)入出金制御A_結合テスト完了
2. Fuzzy acceptance fails, but one-edit candidate exists:
   1. (44)入出金制御B
3. Result:
   1. status = ONE_EDIT_NEAR
   2. H yellow
   3. K-AA blank, AB blank
   4. AO contains Ledger候補 note

NO_MATCH example:
1. UPDATE H: PB12345678_(91)認証基盤全面刷新_結合テスト完了
2. No safe exact/family/fuzzy/one-edit candidate survives guards
3. Result:
   1. status = NO_MATCH
   2. H red text
   3. K-AA blank, AB blank
   4. AO optional hint only

### Alias-aware matching and deploy expansion

The real matching rule treats company-code aliases as equivalent in the same-marker exact path (Step 2), not only after a key is resolved. This is required because a ledger row such as `(91)NISA残高表示` must be accepted for an UPDATE row with `(44)NISA残高表示` when the alias map says `44 <-> 91`. This applies equally to every pair below, not only `44 <-> 91`.

Equivalent code mapping (bidirectional) used for both identity matching and deploy expansion:
- `0D <-> 0D`
- `91 <-> 44`
- `90 <-> 90`
- `0H <-> 0H`
- `52 <-> 52`
- `P0 <-> P0`
- `09 <-> 09`
- `0C <-> 0C`
- `0G <-> 0G`
- `92 <-> 0F`
- `93 <-> 0X`
- `94 <-> 46`

Source of truth: this list is read from the hidden Sheet[設定] column `ENV_ALIAS_MAP` (rows below that header, format `CODE:CODE`) each time the macro runs, so editing that column in Excel changes matching behavior without any code change. The 12 pairs above are only used as a fallback if the sheet column is missing or empty.

The matching flow (Step 2) becomes:
1. normalize project name and marker
2. check exact identity with the literal same marker
3. if not found, check exact identity with any alias-equivalent marker (using the table above, checked both directions)
4. if still not found, continue to shared/no-marker exact path (Step 3), then family/fuzzy/one-edit tiers

The same alias equivalence is also used when building the deploy set from `本実施環境`, so a row whose `本実施環境` is `44` also marks the equivalent `91` side (and vice versa) ? this matters because PR disables columns `90/91/92/93` while AP/BATCH disable `08/0H/52/09/44/0F/0X`, so the alias side that is not disabled on a given server is what actually becomes visible.

Example:
1. SVN input: `PB99600001_(44)NISA残高表示_結合テスト完了`
2. Ledger row: `(91)NISA残高表示`
3. Result: accepted at Step 2 (exact + alias-equivalent marker) as `EXACT_SINGLE`, because `44` and `91` are alias-equivalent ? this no longer falls through to Step 3+.
4. Deploy mark behavior: the visible ○/－ mark is based on the equivalent `44`/`91` deploy set derived from `本実施環境`, filtered by the server's disabled-column list ? not just the raw single code on the ledger row.

This is the required behavior for the current workbook logic; the alias rule is part of the Step 2 identity check and the deploy decision itself, not a separate later-tier workaround.

Deploy expansion example (why the alias map matters for K-AA columns):
1. Ledger row has `本実施環境` = `44` only (raw text, no `91` written anywhere).
2. Because `44 <-> 91` are alias-equivalent, the deploy set built for this ledger row is `{44, 91}`, not just `{44}`.
3. On `PR層` (disabled codes: `90,91,92,93`): column `91` is blank because it is disabled; column `44` is not disabled, and since `44` is in the deploy set the cell shows `－`.
4. On `AP層`/`BATCH` (disabled codes: `08,0H,52,09,44,44 rch,0F,0X`): column `44` is blank because it is disabled; column `91` is not disabled, and since `91` is also in the deploy set (thanks to the alias expansion) the cell shows `－` instead of the misleading `○`.
5. Without the alias expansion, step 4's `91` column would incorrectly show `○` (looks like "not yet configured") even though `44` already covers it.

---

## 7) Quick reading guide for new tester
If you are new, check in this order:
1. Open UPDATE sheet after run.
2. Check H color first.
3. Check whether K-AA and AB are filled or blank.
4. Check AO note for Ledger候補 text.
5. Compare against status table in section 6.

If H is yellow or red, that row requires review.

---

## 8) svn.exe Missing Behavior (User Message)
If svn.exe is not installed or not found:
1. Size and TimeStamp (F/G) stay blank.
2. Run continues for other logic.
3. The warning is queued during SVN step and shown after the progress window closes:
   - svn.exe が見つからないため、Size・TimeStamp は取得しません。
4. Final normal completion popup (実行しました) is NOT suppressed by this warning ? if the rest of the run still succeeds, the user sees both popups in sequence after progress closes: the svn.exe warning first, then 実行しました at the very end. (There is no flag in the current source that skips the final popup.)
5. H color is decided by matching status only.
6. Missing Size/TimeStamp alone does not make H red.
7. Red is used only when matching result is NO_MATCH.
