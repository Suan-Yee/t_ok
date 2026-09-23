# Ledger–SVN Matching Test Case Specification

> **Revised test scope:** Run matching cases from Step 2 onward. Name cleanup and marker extraction happen automatically in the macro and are not tester-written tests. The two old `TC-S1` examples below are historical setup examples only; do not execute them as test cases. Use the normal SVN input format and vary the Japanese project name and the ledger rows to exercise matching.

## Scope

This specification is based on the VBA in `TS_SVNログからリスト作成.xlsm`, primarily `EXE_Main.SubResolveLedgerKey`, `SubBuildLedgerEnvMap`, and `SubSetUpdDeployInfo`.

It is written in English for testers who do not read Japanese. All Japanese project names below are fictional test data. Environment codes such as `44` and `91` are test values required to exercise the code paths; they are not project or company names.

## Input and output contract

| Source | Field used by the code | Test data field |
| --- | --- | --- |
| Ledger workbook `WB4実施管理.xlsm`, sheet `WB4実施管理` | header containing `案件名` | **Ledger Project Name** |
| Same ledger row | header containing `本実施環境` | **Ledger Production Environment** |
| Generated UPDATE sheet | column B | **UPDATE Server** |
| Generated UPDATE sheet | column H | **SVN Feature Name** |
| Generated UPDATE sheet | K–AA | **Deployment marks** |
| Generated UPDATE sheet | AB | **Sync value** |
| Generated UPDATE sheet | AO | **Remarks** |

The macro finds the ledger headers using a partial match, then reads all rows below the later of the two headers. A duplicate means two physical ledger rows having the same normalized marker-plus-name identity.

## Common setup and checks

1. Use backup copies of the workbooks. In each test, prepare the ledger with **only** the rows listed in that case unless it says otherwise. This isolates the rule under test.
2. Start with a known-good raw SVN log entry in the input workbook’s `入力` sheet. Keep its revision, author, date, and a file path that normally passes the current extraction filters. Replace only the commit message in the configured `SVN_MSG` block with the case’s listed message. Do not type into generated UPDATE column H; the macro creates it from the commit message.
3. Set the existing input settings so the generated UPDATE row uses server `PR層` (B), unless a case says otherwise. Each case’s `SVN Input` gives the raw commit message, including its normal PB prefix and completion suffix.
4. Run `Create_SVNLOG_LIST_EXE_Start` through the normal process. The matching routine runs while the macro populates UPDATE deployment information.
5. In alias cases, configure the workbook’s `設定` sheet `ENV_ALIAS_MAP` column with the pair named in the case (`91:44` or `92:0F`). The loader treats each pair as bidirectional.
6. Evaluate the generated UPDATE result: H format, K–AA deployment values, AB sync value, and AO remark text.

### Output meanings verified from the VBA

| Final status | H appearance | K–AA and AB | AO behavior |
| --- | --- | --- | --- |
| `EXACT_SINGLE` | Normal black text, no yellow fill | Populated | No forced candidate remark |
| `EXACT_MULTI` | Yellow fill | Blank | `Ledger候補:` remark, including `x2` for duplicate rows |
| `UNIQUE_SINGLE` | Yellow fill | Populated | `Ledger候補:` remark |
| `UNIQUE_MULTI` | Yellow fill | Blank | `Ledger候補:` remark |
| `FUZZY_SINGLE` | Normal black text, no yellow fill | Populated | No forced candidate remark |
| `ONE_EDIT_NEAR` | Yellow fill | Blank | `Ledger候補:` remark |
| `NO_MATCH` | Red font | Blank | Existing memo is retained; a best/second candidate suggestion may be appended |

For populated deployment output, `－` means the environment code is in the matched ledger row’s expanded deployment set, `○` means it is not, and a server-disabled code is blank. With server `PR層`, columns for `90`, `91`, `92`, and `93` are blank. AB is `[ap][wb]` for `PR層`.

## Successful matching

### TC-E2E-01 — Complete literal exact match and deployment output

| Item | Specification |
| --- | --- |
| Test Case ID | TC-E2E-01 |
| Test Case Name | Complete literal exact match and deployment output |
| Purpose | Verify the complete normal path from SVN name parsing through ledger match, alias-expanded deployment calculation, sync output, and no candidate warning. |
| Ledger Input | `案件名`: `(44)架空顧客口座照会API改修`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000001_(44)架空顧客口座照会API改修_結合テスト完了` |
| Matching Rule / Step Being Tested | End-to-end: normalization, literal same-marker exact match, environment expansion, and output writeback. |
| Expected Result | Status `EXACT_SINGLE`. H stays black with no yellow fill. AB is `[ap][wb]`. K–AA is populated: code `44` is `－`; `91` is blank because PR disables it; other enabled codes not in the deployment set are `○`. AO has no forced `Ledger候補:` text. |
| Reasoning / Expected Matching Behavior | The SVN text normalizes to `架空顧客口座照会API改修` and marker `44`. The ledger produces the identical identity. `44` expands to its alias `91` for deployment, but PR hides the `91` column. |

## Automatic pre-match setup (not a manual test step)

The macro prepares the `機能名` value before matching. Testers should not edit VBA or create special malformed-prefix cases for this suite. Keep the PB prefix, project marker, and completion suffix in the normal source format, then vary the project name and ledger rows. There are no Step 1 test cases in this specification; all executable cases begin at Step 2.

## Step 2 — Exact name with literal marker, then alias-equivalent marker

### TC-S2-01 — Literal same-marker exact match

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-01 |
| Test Case Name | Literal same-marker exact match |
| Purpose | Verify the first exact lookup using the literal marker and normalized name. |
| Ledger Input | `案件名`: `(0D)架空取引番号初期化`; `本実施環境`: `0D` |
| SVN Input | B: `PR層`; H: `PB10000004_(0D)架空取引番号初期化_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2, literal marker identity. |
| Expected Result | `EXACT_SINGLE`; H normal; K–AA and AB populated; AO has no forced candidate remark. |
| Reasoning / Expected Matching Behavior | The marker and normalized name form the same identity on both sides. The macro stops before any later tier. |

### TC-S2-02 — Different non-alias marker fails the literal exact rule

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-02 |
| Test Case Name | Different non-alias marker fails the literal exact rule |
| Purpose | Verify that an identical name does not match when both nonblank markers differ and are not aliases. |
| Ledger Input | `案件名`: `(90)架空取引番号初期化`; `本実施環境`: `90` |
| SVN Input | B: `PR層`; H: `PB10000005_(44)架空取引番号初期化_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2 failure, then marker-safety filtering in later tiers. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | `44` and `90` are not equivalent. The unmarked exact path has no candidate. Later family, fuzzy, and one-edit paths accept a marked candidate only when its marker is literal `44`, so `(90)` cannot be selected. |

### TC-S2-03 — Alias-equivalent exact match

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-03 |
| Test Case Name | Alias-equivalent exact match |
| Purpose | Verify that exact matching re-checks names with an alias-equivalent marker. |
| Ledger Input | `案件名`: `(91)架空NISA残高照会`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000006_(44)架空NISA残高照会_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2 alias-aware exact match with configured `91:44`. |
| Expected Result | `EXACT_SINGLE`; H normal; K–AA and AB populated. AO has no forced candidate remark. |
| Reasoning / Expected Matching Behavior | Literal `(44)` identity is absent. The macro iterates exact-name candidates and accepts `(91)` because `SubMarkersEquivalent(44, 91)` is true. |

### TC-S2-04 — Duplicate alias-equivalent identity is ambiguous

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-04 |
| Test Case Name | Duplicate alias-equivalent identity is ambiguous |
| Purpose | Verify duplicate handling after an alias-equivalent exact hit. |
| Ledger Input | Row 1 and Row 2: `案件名`: `(91)架空通信認証設定`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000007_(44)架空通信認証設定_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2 alias-aware exact match, duplicate failure. |
| Expected Result | `EXACT_MULTI`; H yellow; K–AA and AB blank; AO includes `Ledger候補:` and `(91)架空通信認証設定 x2`. |
| Reasoning / Expected Matching Behavior | The single alias-equivalent identity has a row count of two. The code deliberately returns `EXACT_MULTI` rather than choosing either row. |

## Step 3 — Exact match through an unmarked ledger project

### TC-S3-01 — One unmarked exact candidate is accepted

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S3-01 |
| Test Case Name | One unmarked exact candidate is accepted |
| Purpose | Verify the shared/no-marker exact fallback. |
| Ledger Input | `案件名`: `架空共通通知基盤改修`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000008_(44)架空共通通知基盤改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 3 unmarked exact candidate. |
| Expected Result | `EXACT_SINGLE`; H normal; K–AA and AB populated; AO has no forced candidate remark. |
| Reasoning / Expected Matching Behavior | No `(44)` or alias exact identity exists. The code then checks the blank-marker identity with the identical normalized name and accepts the single row. |

### TC-S3-02 — Duplicate unmarked exact candidate is ambiguous

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S3-02 |
| Test Case Name | Duplicate unmarked exact candidate is ambiguous |
| Purpose | Verify the failure path for two physical rows with one unmarked exact identity. |
| Ledger Input | Row 1 and Row 2: `案件名`: `架空帳票基盤更新`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000009_(91)架空帳票基盤更新_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 3 unmarked exact candidate, duplicate failure. |
| Expected Result | `EXACT_MULTI`; H yellow; K–AA and AB blank; AO includes `Ledger候補:` and `架空帳票基盤更新 x2`. |
| Reasoning / Expected Matching Behavior | There is no same-marker or alias exact candidate. The blank-marker identity is found, but its ledger row count is two. |

## Step 4 — Family match (`QUERY_` followed by a suffix)

### TC-S4-01 — One same-marker family candidate is accepted

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S4-01 |
| Test Case Name | One same-marker family candidate is accepted |
| Purpose | Verify family matching when the ledger project begins with the exact query followed by an underscore. |
| Ledger Input | `案件名`: `(44)架空NISA残高照会_オンライン`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000010_(44)架空NISA残高照会_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 4 family candidate. |
| Expected Result | `UNIQUE_SINGLE`; H yellow; K–AA and AB populated; AO includes `Ledger候補: (44)架空NISA残高照会_オンライン`. |
| Reasoning / Expected Matching Behavior | No exact name exists. The candidate starts with `架空NISA残高照会_`, has the literal marker, and is the only family identity. Family matches are intentionally flagged for review even when unique. |

### TC-S4-02 — Multiple family candidates are not selected

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S4-02 |
| Test Case Name | Multiple family candidates are not selected |
| Purpose | Verify ambiguity when more than one same-marker family identity exists. |
| Ledger Input | Row 1: `案件名`: `(91)架空投信申込受付_オンライン`; `本実施環境`: `91`. Row 2: `案件名`: `(91)架空投信申込受付_画面開放`; `本実施環境`: `91`. |
| SVN Input | B: `PR層`; H: `PB10000011_(91)架空投信申込受付_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 4 family candidate, ambiguity failure. |
| Expected Result | `UNIQUE_MULTI`; H yellow; K–AA and AB blank; AO lists both `Ledger候補:` values. |
| Reasoning / Expected Matching Behavior | Both distinct normalized ledger identities start with `架空投信申込受付_`. The code stops at the family tier and does not use fuzzy scoring to choose one. |

## Step 5 — Fuzzy match (Dice threshold and margin)

### TC-S5-01 — Clear high-score fuzzy candidate is accepted

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S5-01 |
| Test Case Name | Clear high-score fuzzy candidate is accepted |
| Purpose | Verify acceptance when the Dice score is at least 0.85 and the score gap to the second candidate is at least 0.05. |
| Ledger Input | `案件名`: `(44)架空顧客情報照会画面表示制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000012_(44)架空顧客情報照会画面表示制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 Dice fuzzy acceptance. |
| Expected Result | `FUZZY_SINGLE`; H normal; K–AA and AB populated; AO has no forced candidate remark. |
| Reasoning / Expected Matching Behavior | The long names differ only in the final business term, so their bigram sets have a high Dice overlap. There is no second ledger identity, so the effective second score is zero and the margin passes. The names do not have the `QUERY_` form needed by Step 4. |

### TC-S5-02 — Near-tied fuzzy candidates are rejected

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S5-02 |
| Test Case Name | Near-tied fuzzy candidates are rejected |
| Purpose | Verify that a strong best match is not accepted when another candidate has an insufficient score gap. |
| Ledger Input | Row 1: `案件名`: `(44)架空本人確認書類画像登録制御改修`; `本実施環境`: `44`. Row 2: `案件名`: `(44)架空本人確認書類画像登録制御追加`; `本実施環境`: `44`. |
| SVN Input | B: `PR層`; H: `PB10000013_(44)架空本人確認書類画像登録制御_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 Dice margin failure, followed by Step 6. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank; AO may contain candidate suggestions. |
| Reasoning / Expected Matching Behavior | Both candidates are similarly close to the query, so `best Dice - second Dice` is below `0.05`. They each add two characters rather than being one edit away, so Step 6 does not recover the match. The underscore-free suffixes ensure these are not Step 4 family candidates. |

## Step 6 — One-edit fallback

### TC-S6-01 — One replacement character is flagged for review

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S6-01 |
| Test Case Name | One replacement character is flagged for review |
| Purpose | Verify the final replacement-character fallback when fuzzy matching is not accepted. |
| Ledger Input | `案件名`: `(44)架空鍵B`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000014_(44)架空鍵A_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 6 one-character replacement. |
| Expected Result | `ONE_EDIT_NEAR`; H yellow; K–AA and AB blank; AO includes `Ledger候補: (44)架空入出金制御B`. |
| Reasoning / Expected Matching Behavior | The normalized loose names have equal length and exactly one differing character. At this short length their unique-bigram Dice score is below `0.85`, so the one-edit fallback flags the row instead of automatically deploying it. |

### TC-S6-02 — Two edits do not satisfy the fallback

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S6-02 |
| Test Case Name | Two edits do not satisfy the fallback |
| Purpose | Verify rejection when the only candidate requires more than one edit. |
| Ledger Input | `案件名`: `(91)架空夜間バッチ監視YZ`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000015_(91)架空夜間バッチ監視X_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 6 failure. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | The candidate needs two inserted characters (`Y` and `Z`) relative to the query. `SubIsSingleEditAway` rejects length differences greater than one. |

### TC-S6-03 — Multiple one-edit candidates are still reported as `ONE_EDIT_NEAR`

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S6-03 |
| Test Case Name | Multiple one-edit candidates are still reported as one-edit near |
| Purpose | Document and test the current implementation’s behavior when more than one fallback candidate exists. |
| Ledger Input | Row 1: `案件名`: `(44)架空送信制御B`; `本実施環境`: `44`. Row 2: `案件名`: `(44)架空送信制御C`; `本実施環境`: `44`. |
| SVN Input | B: `PR層`; H: `PB10000016_(44)架空送信制御A_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 6 multiple-candidate behavior. |
| Expected Result | `ONE_EDIT_NEAR`, not `UNIQUE_MULTI`; H yellow; K–AA and AB blank; AO lists both candidates. |
| Reasoning / Expected Matching Behavior | The implementation increments `FALLBACK_COUNT` for every one-edit candidate but returns `ONE_EDIT_NEAR` whenever the count is greater than zero. It does not require a unique fallback candidate, despite the nearby code comment. This is a regression test for actual behavior. |

## Candidate guard rules

### TC-G-01 — Matching project number permits a fuzzy candidate

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-01 |
| Test Case Name | Matching requirement number permits a fuzzy candidate |
| Purpose | Verify the pass condition of the project-number conflict guard. |
| Ledger Input | `案件名`: `(44)架空要件1顧客照会API制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000017_(44)架空要件1_顧客照会API制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Number-conflict guard for `要件`. |
| Expected Result | `FUZZY_SINGLE`; H normal; K–AA and AB populated. |
| Reasoning / Expected Matching Behavior | Both sides contain `要件1`, so the guard does not exclude the candidate. The names are otherwise very similar but not exact because of separator and final-term differences. |

### TC-G-02 — Different requirement number excludes a close candidate

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-02 |
| Test Case Name | Different requirement number excludes a close candidate |
| Purpose | Verify rejection on a `要件` number mismatch. |
| Ledger Input | `案件名`: `(44)架空要件2顧客照会API制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000018_(44)架空要件1_顧客照会API制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Number-conflict guard for `要件`, failure. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | `SubHasProjectNumberConflict` extracts `1` and `2` after `要件` and rejects the candidate before Dice and one-edit matching. |

### TC-G-03 — Different phase number excludes a close candidate

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-03 |
| Test Case Name | Different phase number excludes a close candidate |
| Purpose | Verify the independent `フェーズ` number conflict check. |
| Ledger Input | `案件名`: `(91)架空フェーズ4帳票出力制御改善`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000019_(91)架空フェーズ3_帳票出力制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Number-conflict guard for `フェーズ`, failure. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | The names are otherwise deliberately close. The extracted phase values `3` and `4` differ, so the candidate is filtered out. This confirms that the guard is not limited to `要件`. |

### TC-G-04 — A shorter prefix candidate is blocked by the stem guard

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-04 |
| Test Case Name | A shorter prefix candidate is blocked by the stem guard |
| Purpose | Verify that a generic ledger project cannot be selected for a more specific query. |
| Ledger Input | `案件名`: `(44)架空顧客照会`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000020_(44)架空顧客照会API制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Stem guard, failure. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | Splitting on underscores shows the ledger name is a leading, shorter sequence of the query. `SubIsProjectStem` excludes it from fuzzy and one-edit evaluation. |

### TC-G-05 — A non-stem close candidate remains eligible

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-05 |
| Test Case Name | A non-stem close candidate remains eligible |
| Purpose | Verify the pass condition of the stem guard. |
| Ledger Input | `案件名`: `(44)架空取引履歴照会API制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000021_(44)架空取引履歴照会API制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Stem guard pass, then fuzzy match. |
| Expected Result | `FUZZY_SINGLE`; H normal; K–AA and AB populated. |
| Reasoning / Expected Matching Behavior | The candidate is a complete peer name, not a shorter leading token sequence of the query. It survives the guard and is the sole high-scoring fuzzy candidate. |

### TC-G-06 — Alias equivalence is not used by later fuzzy tiers

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-06 |
| Test Case Name | Alias equivalence is not used by later fuzzy tiers |
| Purpose | Verify marker safety after Step 2. |
| Ledger Input | `案件名`: `(91)架空認証連携制御改善`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000022_(44)架空認証連携制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Marker safety in Steps 4–6; configured alias `91:44` is present. |
| Expected Result | `NO_MATCH`; H font red; K–AA and AB blank. |
| Reasoning / Expected Matching Behavior | Step 2 alias handling cannot apply because the names are not exact. Step 4 requires a literal same marker for marked family candidates. Steps 5 and 6 admit a marked candidate only when its marker literally equals `44`; they do not call `SubMarkersEquivalent`. |

### TC-G-07 — Literal marker allows the same fuzzy shape

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-07 |
| Test Case Name | Literal marker allows the same fuzzy shape |
| Purpose | Verify the pass condition paired with TC-G-06. |
| Ledger Input | `案件名`: `(44)架空認証連携制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000023_(44)架空認証連携制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Marker safety pass, then fuzzy match. |
| Expected Result | `FUZZY_SINGLE`; H normal; K–AA and AB populated. |
| Reasoning / Expected Matching Behavior | Changing only the ledger marker from `91` to the literal `44` allows the candidate through later-tier marker filtering. It is then the only close fuzzy candidate. |

## Notes for test implementation

- The status strings are internal VBA values. Validate them indirectly through the stated H/K–AA/AB/AO behavior. The case’s H value is the raw SVN commit message used to generate the feature name, not a value to paste into output H.
- Fuzzy scoring uses **unique character bigrams** after removing underscores and periods. Levenshtein ratio only breaks equal-Dice ranking; it does not replace the `0.85` Dice threshold or `0.05` Dice-margin rule.
- Family matching is strictly `candidate = QUERY + "_" + suffix`. A visually similar candidate without the underscore must not be assumed to be a family match.
- `本実施環境` is parsed using many separators and valid codes are alias-expanded for deployment output. Matching aliases are read from `設定!ENV_ALIAS_MAP` at runtime; update the test’s expected behavior if that configuration changes.

## Additional matching cases

These cases extend the core set with more project names and cover alternative paths through the same matching tiers. Keep the ledger limited to each case’s listed rows.

### TC-S2-05 — A second alias pair matches an exact name

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-05 |
| Test Case Name | A second alias pair matches an exact name |
| Purpose | Confirm alias matching with a pair other than `44` and `91`. |
| Ledger Input | One row: `案件名`: `(0F)架空電子明細照会`; `本実施環境`: `0F` |
| SVN Input | B: `PR層`; H: `PB10000024_(92)架空電子明細照会_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2 alias exact match; configure `92:0F` in `設定!ENV_ALIAS_MAP`. |
| Expected Result | `EXACT_SINGLE`; H normal; deployment and sync populated; no forced candidate remark. |
| Reasoning / Expected Matching Behavior | Names are identical after automatic preparation. The only identity difference is the configured alias pair `92`/`0F`, which the macro checks in both directions. |

### TC-S2-06 — Literal marker candidate wins when an alias candidate also exists

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S2-06 |
| Test Case Name | Literal marker candidate wins when an alias candidate also exists |
| Purpose | Verify priority of the literal identity over an alias-equivalent identity. |
| Ledger Input | Row 1: `案件名`: `(44)架空外貨残高照会`; `本実施環境`: `44`. Row 2: `案件名`: `(91)架空外貨残高照会`; `本実施環境`: `91`. |
| SVN Input | B: `PR層`; H: `PB10000025_(44)架空外貨残高照会_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 2 literal exact priority over alias search. |
| Expected Result | `EXACT_SINGLE`, using the `(44)` row. H normal; deployment and sync populated. |
| Reasoning / Expected Matching Behavior | The resolver returns immediately when the literal `(44)` key exists. It does not collect the alias `(91)` row as a second match. |

### TC-S3-03 — Unmarked exact fallback is used despite an unrelated marked row

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S3-03 |
| Test Case Name | Unmarked exact fallback is used despite an unrelated marked row |
| Purpose | Verify that the exact shared candidate is used after same-marker and alias exact candidates are absent. |
| Ledger Input | Row 1: `案件名`: `(90)架空電子申請履歴`; `本実施環境`: `90`. Row 2: `案件名`: `架空電子申請履歴`; `本実施環境`: `44`. |
| SVN Input | B: `PR層`; H: `PB10000026_(44)架空電子申請履歴_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 3 shared/unmarked exact fallback. |
| Expected Result | `EXACT_SINGLE`, using the unmarked row. H normal; deployment and sync populated. |
| Reasoning / Expected Matching Behavior | `(90)` is not an alias of `(44)`, so it does not satisfy the marked exact check. The resolver then looks for the exact blank-marker identity and finds exactly one such row. |

### TC-S4-03 — Unmarked family candidate is used when no same-marker family exists

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S4-03 |
| Test Case Name | Unmarked family candidate is used when no same-marker family exists |
| Purpose | Verify the shared family fallback. |
| Ledger Input | One row: `案件名`: `架空決済通知制御改修_配信設定`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000027_(44)架空決済通知制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 4 unmarked family candidate. |
| Expected Result | `UNIQUE_SINGLE`; H yellow; deployment and sync populated; AO lists the selected ledger candidate. |
| Reasoning / Expected Matching Behavior | There is no exact candidate and no marked family candidate. The resolver’s second family pass permits blank-marker candidates and finds one candidate starting with `QUERY_`. |

### TC-S4-04 — A suffix without the required underscore is not a family match

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S4-04 |
| Test Case Name | A suffix without the required underscore is not a family match |
| Purpose | Verify the family boundary and that the row does not get accepted by a later tier. |
| Ledger Input | One row: `案件名`: `(44)架空顧客照会追加`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000028_(44)架空顧客照会_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 4 family failure, with later tiers also exercised. |
| Expected Result | `NO_MATCH`; H red; deployment and sync blank. |
| Reasoning / Expected Matching Behavior | Family matching requires the ledger name to start with the exact query followed by `_`. This row has no underscore at that boundary. The added word also requires more than one edit, and the short names should remain below the fuzzy threshold. |

### TC-S5-03 — A second distinct fuzzy name is accepted

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S5-03 |
| Test Case Name | A second distinct fuzzy name is accepted |
| Purpose | Confirm fuzzy acceptance on a different Japanese project name. |
| Ledger Input | One row: `案件名`: `(91)架空振込限度額表示改善`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000029_(91)架空振込限度額表示改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 Dice threshold and margin pass. |
| Expected Result | `FUZZY_SINGLE`; H normal; deployment and sync populated. |
| Reasoning / Expected Matching Behavior | The sole ledger name differs from the query by the final character in the final term. Its bigram overlap is well above `0.85`; with no runner-up identity, the score margin also passes. |

### TC-S5-04 — A distant fuzzy candidate is rejected and has no one-edit match

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S5-04 |
| Test Case Name | A distant fuzzy candidate is rejected and has no one-edit match |
| Purpose | Verify failure of the Dice minimum when there is no close fallback candidate. |
| Ledger Input | One row: `案件名`: `(44)架空本人確認画像保存方式`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000030_(44)架空電子明細CSV出力制御_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 threshold failure, then Step 6 no candidate. |
| Expected Result | `NO_MATCH`; H red; deployment and sync blank; AO may show the distant candidate as a suggestion. |
| Reasoning / Expected Matching Behavior | The names share only generic characters and should have a Dice score below `0.85`. Their lengths and character sequences are not one edit apart. |

### TC-S5-05 — A fuzzy hit whose ledger identity has duplicate rows is ambiguous

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S5-05 |
| Test Case Name | A fuzzy hit whose ledger identity has duplicate rows is ambiguous |
| Purpose | Verify duplicate-row handling after the fuzzy candidate wins scoring. |
| Ledger Input | Row 1 and Row 2: `案件名`: `(44)架空振込限度額表示改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000031_(44)架空振込限度額表示改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 passes score and margin, then duplicate identity handling. |
| Expected Result | `EXACT_MULTI`; H yellow; deployment and sync blank; AO contains the candidate with `x2`. |
| Reasoning / Expected Matching Behavior | The fuzzy winner’s normalized marker/name key has two physical ledger rows. The code returns `EXACT_MULTI` for a duplicate fuzzy winner rather than `FUZZY_SINGLE`. |

### TC-S6-04 — One inserted character is flagged for review

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S6-04 |
| Test Case Name | One inserted character is flagged for review |
| Purpose | Cover the insertion form of the one-edit rule. |
| Ledger Input | One row: `案件名`: `(44)架空鍵B`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000032_(44)架空鍵_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 6 one-character insertion/deletion comparison. |
| Expected Result | `ONE_EDIT_NEAR`; H yellow; deployment and sync blank; AO names the candidate. |
| Reasoning / Expected Matching Behavior | After automatic name preparation, the ledger candidate contains one additional terminal character. The short names score below `0.85`, then the single inserted character is detected by the fallback. |

### TC-S6-05 — One deleted character is flagged for review

| Item | Specification |
| --- | --- |
| Test Case ID | TC-S6-05 |
| Test Case Name | One deleted character is flagged for review |
| Purpose | Cover the deletion form of the one-edit rule. |
| Ledger Input | One row: `案件名`: `(91)架空鍵`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000033_(91)架空鍵改_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 6 one-character insertion/deletion comparison. |
| Expected Result | `ONE_EDIT_NEAR`; H yellow; deployment and sync blank; AO names the candidate. |
| Reasoning / Expected Matching Behavior | The SVN query contains one extra terminal character compared with the only ledger candidate. The short names score below `0.85`, so the one-character deletion is reported by the fallback. |

### TC-G-08 — Equal phase numbers pass the phase conflict guard

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-08 |
| Test Case Name | Equal phase numbers pass the phase conflict guard |
| Purpose | Pair the phase mismatch failure with a matching-number pass case. |
| Ledger Input | One row: `案件名`: `(91)架空フェーズ3帳票出力制御改善`; `本実施環境`: `91` |
| SVN Input | B: `PR層`; H: `PB10000034_(91)架空フェーズ3帳票出力制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 candidate filter for `フェーズ` numbers. |
| Expected Result | `FUZZY_SINGLE`; H normal; deployment and sync populated. |
| Reasoning / Expected Matching Behavior | Both names contain `フェーズ3`, so the number conflict filter permits the candidate. The remaining one-character name difference yields a high fuzzy score. |

### TC-G-09 — Different PH numbers exclude a close candidate

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-09 |
| Test Case Name | Different PH numbers exclude a close candidate |
| Purpose | Verify the third numbered-label conflict check. |
| Ledger Input | One row: `(44)架空PH2顧客検索API制御改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000035_(44)架空PH1顧客検索API制御改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Number-conflict guard for `PH`, failure. |
| Expected Result | `NO_MATCH`; H red; deployment and sync blank. |
| Reasoning / Expected Matching Behavior | Both names contain a PH number, but `1` and `2` conflict. The close candidate is excluded before fuzzy and one-edit scoring. |

### TC-G-10 — A numbered label present on only one side does not conflict for phase

| Item | Specification |
| --- | --- |
| Test Case ID | TC-G-10 |
| Test Case Name | A phase number present on only one side does not conflict |
| Purpose | Verify the actual guard condition for a phase number missing from one candidate. |
| Ledger Input | One row: `案件名`: `(44)架空帳票出力制御管理システム連携処理顧客口座照会API配信環境更新処理情報管理改善`; `本実施環境`: `44` |
| SVN Input | B: `PR層`; H: `PB10000036_(44)架空フェーズ3帳票出力制御管理システム連携処理顧客口座照会API配信環境更新処理情報管理改修_結合テスト完了` |
| Matching Rule / Step Being Tested | Step 5 `フェーズ` conflict guard boundary. |
| Expected Result | `FUZZY_SINGLE`; H normal; deployment and sync populated. |
| Reasoning / Expected Matching Behavior | For `フェーズ` and `PH`, the VBA rejects only when both sides contain a number and those numbers differ. The ledger candidate has no phase number, so this guard does not reject it. The shared long name keeps the Dice score above `0.85`; the final term differs, and there is no runner-up candidate. |
