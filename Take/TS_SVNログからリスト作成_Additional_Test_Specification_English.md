# TS_SVN Log List Generator — Additional Test Specification

Date: 2026-10-20  
Status: Optional additions; not executed. Existing specifications, Excel workbooks, and evidence files have not been modified by creating this document.

## 1. References and instructions

- Japanese version of this additional specification: [TS_SVNログからリスト作成_追加テスト仕様書_日本語.md](./TS_SVNログからリスト作成_追加テスト仕様書_日本語.md).
- Original specification: [TS_SVNログからリスト作成_テスト仕様書_日本語.md](./TS_SVNログからリスト作成_テスト仕様書_日本語.md).
- Current reference: the `テストケース` sheet in the updated, root-level [TS_SVNログからリスト作成_単体テスト.xlsx](./TS_SVNログからリスト作成_単体テスト.xlsx). Recent generic wording and condition corrections are present in this Excel workbook but are not all reflected in the original Markdown. Use the updated Excel if they differ.
- Tool: [TS_SVNログからリスト作成.xlsm](./TS_SVNログからリスト作成.xlsm).
- Coverage review: [追加テスト候補_カバレッジ確認_20261020.md](./レビュー結果/追加テスト候補_カバレッジ確認_20261020.md). “Source candidate” below refers to the A/B identifiers in that review.

This document converts the VBA coverage-review suggestions into cases that can be copied into the existing specification. All additions are optional. Select the cases relevant to your available time and usage.

Append selected cases to the end of their existing group. Keep existing case numbers unchanged. The new numbers are proposed numbers; if any have been used by the time you add them, assign unused numbers within the same group.

Copy **Operation** and **Expected result** into the corresponding Excel fields. Use **Evidence** as a capture checklist. Leave the execution record unfilled until testing is complete. For a case with conditions A/B/C, capture and record each condition separately. Do not mark an unexecuted condition as passed.

The Japanese UI labels and exact Japanese messages are retained so they can be compared with Japanese Excel.

## 2. Where to add the cases

| Group | Current final case | Proposed additional cases | Content | Evidence workbook |
| --- | --- | --- | --- | --- |
| 1 — Normal operations and buttons | TC-1-1-3 | TC-1-1-4 to TC-1-1-5 | Recovery after errors; full file paths | `02.エビデンス/テストケース1.xlsx` |
| 2 — Input validation and file errors | TC-2-1-5 | TC-2-1-6 to TC-2-1-8 | Missing headers; unusable ledger; nonexistent paths | `02.エビデンス/テストケース2.xlsx` |
| 3 — File extraction and SVN information | TC-3-1-4 | TC-3-1-5 to TC-3-1-9 | Revision metadata; log parsing; path and size boundaries | `02.エビデンス/テストケース3.xlsx` |
| 4 — Ledger matching | TC-4-1-27 | TC-4-1-28 to TC-4-1-33 | Candidate priority; unmarked projects; aliases; approximate matching | `02.エビデンス/テストケース4.xlsx` |
| 5 — Inventory export | TC-5-1-3 | TC-5-1-4 to TC-5-1-10 | Company selection; merging; cleanup; output protection | `02.エビデンス/テストケース5.xlsx` |

In the Excel `テストケース` sheet, insert rows after the current final case of the relevant group. In the Markdown specification, insert the cases before the next group heading. Insert group 5 additions before the supplementary notes.

Use case numbers to locate insertion positions because Excel row numbers will change when rows are inserted.

In the corresponding evidence workbook, add sheets using the existing naming convention, such as `1-1-4` or `5-1-4`. Multiple executions may share one sheet if clearly labeled “Condition A,” “Condition B,” etc.

If time is limited, suggested starting cases are **TC-5-1-4, TC-5-1-5, and TC-3-1-5**.

## 3. Common preparation

- Use test copies of the tool, ledger, template, and inventory workbook. Company-code-column deletion and cancellation remain outside the existing scope.
- Use generic file and project names. Record the actual logs, companies, projects, environments, names, paths, and counts. Keep rule-specific code pairs such as 91/44 and 92/0F where those mappings are the test condition.
- The upper `リストにする` button generates UPDATE. The lower button exports to the inventory workbook. Record which button was used.
- Identify UPDATE company columns by the company-code headers in row 5. Disabled companies differ between PR and AP/BATCH; retain the required blank values for disabled columns.
- Inventory-only tests may start from a normally generated test UPDATE and manually adjust the necessary values. Record that the data was adjusted for an isolated inventory test and capture UPDATE immediately before export. Do not press the upper button after adjustment, because it regenerates UPDATE.
- Capture both the comparison source and the result. Identify files by path, size, and timestamp where relevant, rather than filename alone. Make complete project names and multiline cells readable using the formula bar or another suitable view.
- Expected results below are review criteria, not execution results. If the result differs, record NG or “Requires investigation”; do not automatically change the expectation to fit the evidence.

## 4. Group 1 — Normal operations and buttons

Insertion position: **after TC-1-1-3**.

### TC-1-1-4 — Run successfully after recovering from an error

**Source candidate:** B10. Evidence can be captured immediately after TC-2-1-6 to 8 or TC-5-1-9.

**Operation:** Trigger a reproducible error, such as invalid input or an inventory output file being open. Without closing Excel, correct the cause and run the same operation again. Test main generation and inventory export as separate conditions if checking both.

**Expected result:** The operation runs successfully after correction. The result matches the current input and the appropriate completion message appears. Progress indicators finish, Excel returns to its previous operating state, and unnecessary temporary UPDATE sheets do not remain. Main generation clears previous output values before validation, so this case does not require those values to survive the error.

**Evidence:** Error condition and message; corrected input; successful output and message; worksheet tabs. If checking calculation/events settings, record the verification method and before-and-after values.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-1-1-5 — Specify the template and ledger using full file paths

**Source candidate:** Normal-path part of B07. Related: TC-1-1-1.

**Operation:** Prepare a normal PR log and matching ledger. Enter the full required template file path in C12 and the full `WB4実施管理.xlsm` path in C15. Generate UPDATE and compare it with an execution using folder paths and the same data.

**Expected result:** Both full file paths are accepted. Target files, project matching, company marks, and synchronization values match the folder-path execution. Processing completes successfully. Use the workbook names required by the current tool.

**Evidence:** C12/C15; outputs from the folder-path and full-file-path executions; completion messages.

**Execution result / Tester / Date:** __________  **Review:** __________

## 5. Group 2 — Input validation and file errors

Insertion position: **after TC-2-1-5**.

### TC-2-1-6 — Required SVN log headers are missing

**Source candidate:** B05. Related: TC-2-1-3.

**Operation:** Keep both workbook paths and the log type valid. Starting from a normal log, remove one configured required header at a time: Revision, Author, Date, and Message. Run four separate conditions. Ensure the removed header text does not remain elsewhere in the input.

**Expected result:** Processing stops with a system-error notification containing the corresponding identifier: Revision `(SVN_REV)`, Author `(SVN_ATH)`, Date `(SVN_DATE)`, or Message `(SVN_MSG)`. No new UPDATE result or successful completion message is produced. Previous output values are cleared first.

**Evidence:** Input for each condition; explanation of the removed header; corresponding error message; resulting output state.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-2-1-7 — Ledger exists, but usable project data cannot be obtained

**Source candidate:** B06. Related: TC-2-1-5 and TC-4-1-1/17/23.

**Operation:** Use a valid template and a normal log containing eligible files. Prepare separate test copies of `WB4実施管理.xlsm` for A: required headers exist but there are no project rows; B: the `案件名` header is missing; C: the `本実施環境` header is missing; D: the required ledger worksheet is missing. Run each condition with its corresponding C15 path. Ensure missing header text is not left elsewhere in the ledger.

**Expected result:** The tool reports `共有台帳を取得できませんでした。` and does not finish successfully. An invalid or empty ledger is not treated as the normal “valid ledger, but no matching project” condition. Intermediate list sheets may exist; do not treat them as a successful UPDATE result.

**Evidence:** Ledger sheets, headers and data state; input path; error message; resulting UPDATE state. Record each condition separately.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-2-1-8 — Nonexistent folder or explicitly specified file

**Source candidate:** Error-path part of B07. Related: TC-2-1-4/5.

**Operation:** Keep other inputs valid. Test C12 and C15 separately using A: a path whose parent folder does not exist; B: a full file path whose parent exists but the specified file does not. For A, ensure the parent itself is absent, rather than only the last path component. For B, keep the required workbook in the parent folder and specify a different nonexistent file to distinguish the validation branch.

**Expected result:** A reports that the relevant folder does not exist or cannot be accessed. B reports that the explicitly specified file cannot be found. The notification identifies the correct C12/C15 cell and path. There is no successful completion or new output. Previous output values are cleared first.

**Evidence:** Entered path; folder/file existence; error message; output state.

**Execution result / Tester / Date:** __________  **Review:** __________

## 6. Group 3 — File extraction and SVN information

Insertion position: **after TC-3-1-4**. SVN metadata and parsing checks are placed here because they verify generated list content.

### TC-3-1-5 — Verify Size and TimeStamp for different revisions of the same file

**Source candidate:** A08. Related: TC-3-1-3 and TC-4-1-14/21/27.

**Operation:** Choose a file changed in two revisions. Prepare logs and ledger data allowing both file rows to be included. Before execution, independently record the correct file size and last-commit timestamp at each revision from SVN history. Generate UPDATE using a log containing both revisions.

**Expected result:** UPDATE F/G match the file information at each row's revision. The latest information, or one revision's information, is not used for both rows. Compare timestamps in JST. If the file was not changed in the selected revision, use its last-commit timestamp at that point, rather than the timestamp of an unrelated revision.

**Evidence:** Input logs; independently verified SVN revision/path/size/time; Revision values in リスト; corresponding UPDATE F/G. Different project names alone do not demonstrate this case.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-3-1-6 — SVN information cannot be obtained

**Source candidate:** A09.

**Operation:** A: Under the same SVN root, mix an accessible file with an otherwise eligible file that does not exist at the specified revision. Keep ledger matching valid. Authentication or connection failures may be additional separate conditions in a test environment. B: If practical, use an isolated environment where `svn.exe` cannot be detected. Do not remove the normal SVN installation merely to perform B.

**Expected result:** For A, unavailable rows have blank F/G, a reason in AO, and an unavailable-file-count notification. Accessible rows retain correct metadata. For B, the tool reports that Size/TimeStamp will not be obtained because `svn.exe` was not found; F/G remain blank, and a separate AO reason for every row is not required. Files are not removed solely because metadata retrieval failed. Valid ledger matching still supplies company marks and synchronization values.

**Evidence:** Preparation method for each condition; input log; accessible/unavailable rows; F/G and AO; notifications. Mark B untested if it cannot be reproduced.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-3-1-7 — Japanese logs, delimiter fallback, copy information, and multiline messages

**Source candidate:** B04.

**Operation:** Test separately: A: Japanese log headers registered in 設定; B: a blank delimiter field; C: a configured delimiter that does not occur in the file line; D: trailing copy-source information; E: a multiline message ending with `----`. Keep the configured log-type text in each file line. For E, prepare a ledger project matching the combined message.

**Expected result:** A extracts revision, author, date, and message correctly. B/C fall back to the log-type text and retain the filename; the complete extracted path need not be identical to the usual delimiter result. D excludes copy-source descriptions from PATH/FILE. E joins message lines with `__` without mixing in the next revision. Filtering and UPDATE output correspond to the intended files.

**Evidence:** Input and delimiter for each condition; parsed PATH/FILE/Revision/Author/Date/Message in リスト; リストedit and UPDATE. Running Japanese Excel alone does not demonstrate condition A.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-3-1-8 — Special paths and filename boundaries

**Source candidate:** B08. Select the conditions relevant to actual usage.

**Operation:** Use valid projects and completion messages. Test separately: A: accessible SVN paths/filenames containing Japanese characters or spaces; B: PR paths under `webbroker3/P0_P0/`, `webbroker3/P0_09/`, and `webbroker3/rc_<valid company code>/`; C: a BATCH path whose server after `/trunk/` is not BTserver; D: a BATCH directory matching neither the configured allowed nor excluded lists; E: an Added BATCH entry without an extension under an allowed directory. If all rows are excluded, check the corresponding no-target notification.

**Expected result:** A retains readable names and retrieves metadata for the correct file. B produces M=`/P0/`, M=`/09/`, and K=`webbroker3/rc_` respectively, excluding those rows from UPDATE. C records the server name in K and excludes the row. D records `対象外DIR：<directory>` in K and excludes the row. E is classified by the current implementation as K=`SVNフォルダ追加` and excluded. If E is actually an executable file, check whether this matches the business requirement; do not automatically mark the business requirement passed.

**Evidence:** Original action and full path; K–N marks; UPDATE; SVN comparison data for A. Explain whether E represents a file or folder.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-3-1-9 — Row-count and Japanese text-length boundaries

**Source candidate:** B09.

**Operation:** A: Run separate logs containing 256 and 257 eligible, nonduplicate files. B: Run Japanese log lines/messages at or below 256 bytes and above 256 bytes under the environment's applicable Windows code page. Keep the completion-marker text where truncation will not remove it. Evaluate project-matching effects separately.

**Expected result:** A produces matching counts, final rows, and numbering in リスト, リストedit, and UPDATE; the 257th file is not lost. B retains short values and applies the current truncation ending in `...` to long org/Message values. File/path extraction remains intact. Record corrupted characters or matching problems as NG or requiring investigation. Full original text retention is not expected where truncation applies.

**Evidence:** Count/byte-length calculation method; inputs; first/last rows and totals; complete long-cell contents; corresponding output. Record the character-code environment.

**Execution result / Tester / Date:** __________  **Review:** __________

## 7. Group 4 — Ledger matching

Insertion position: **after TC-4-1-27**. Do not move existing PR/AP/BATCH cases. Start with PR for shared matching logic; add AP/BATCH runs where layer-specific differences need checking.

### TC-4-1-28 — Matching priority when candidate types coexist

**Source candidate:** A10. Related: TC-4-1-2/4/6/9.

**Operation:** Use a PR log with a company marker. In one ledger, prepare one same-marker exact match, one alias-marker exact match, one unmarked exact match, and one derived-name candidate. Give each a distinguishable `本実施環境`. A: run with all candidates. B: remove only the same-marker exact match and run again.

**Expected result:** A selects the same-marker exact match. B selects the alias-marker exact match ahead of the unmarked or derived candidates. Company marks correspond only to the selected candidate; environments are not combined. PR synchronization is populated without unnecessary matching-review remarks.

**Evidence:** Log project name; all competing ledger rows and environments; UPDATE H, company columns, AB, and AO for A/B.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-4-1-29 — Log project has no company marker

**Source candidate:** A11. Reverse condition of TC-4-1-4/5.

**Operation:** Use an unmarked log project name. A: the ledger contains one same-name project with a company marker. B: it contains two same-name projects with different markers. Run separately without other matching candidates.

**Expected result:** A adopts the unique project and populates company marks and PR synchronization. B does not select a project automatically: H is yellow, K:AA and AB are blank, and AO identifies duplicate/ambiguous candidates.

**Evidence:** Unmarked log project; ledger conditions A/B; UPDATE H, company columns, AB, and AO.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-4-1-30 — Alias codes directly in 本実施環境

**Source candidate:** A12. Related: corrected TC-4-1-10/11 and TC-4-1-20/26.

**Operation:** Make log and ledger project names exact matches. Keep mappings 44/91 and 92/0F. Run PR separately with A: `本実施環境 = 91`; B: `本実施環境 = 92`. Change the environment value rather than changing the project's company marker.

**Expected result:** A produces `－` for company44; B produces `－` for company0F. Other enabled companies receive ○. Disabled PR company columns remain blank. AB is `[ap][wb]`, without unnecessary matching-review remarks.

**Evidence:** Alias settings; exact-match project names; each environment value; company-code headers and results; AB and AO.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-4-1-31 — Do not automatically choose between similarly close candidates

**Source candidate:** B01. Related: TC-4-1-8/13.

**Operation:** Prepare two similarly close ledger candidates for a PR project, with the same company marker and no exact or derived match. Use names that do not satisfy the required winning margin of 0.05. Record preparation scores against the automatic acceptance rule: highest score at least 0.85 and margin at least 0.05. Avoid short names that trigger the separate one-character fallback.

**Expected result:** Neither candidate is automatically selected. Company columns and AB remain blank. For this condition, H is red and AO contains unmatched/candidate information. If preparation instead triggers the one-character-review branch, record it separately; that does not verify this score-margin condition.

**Evidence:** Log; all candidates and environments; preparation scores/margin; UPDATE H, company columns, AB, and AO.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-4-1-32 — Different requirement or phase numbers prevent approximate adoption

**Source candidate:** B02.

**Operation:** Use similar long project names with the same company marker. Test separately: A: different requirement numbers; B: different フェーズ numbers present in both names; C: different PH numbers present in both names. Avoid exact and derived matches. Use names that would otherwise be approximate candidates, and do not provide another acceptable candidate.

**Expected result:** The different-number project is not adopted through approximate matching. Company columns and AB remain blank, H is red, and AO contains unmatched information. The different-number project's environment is not used.

**Evidence:** Log/ledger names showing the number difference; ledger environments; UPDATE H, company columns, AB, and AO for each condition.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-4-1-33 — Project-name spacing, separators, and English letter case

**Source candidate:** B03. Related: TC-4-1-15 and the original specification's supplementary notes.

**Operation:** Keep company markers in half-width characters. Use English letters in the project text and one ledger candidate per run. Change only A: English uppercase/lowercase; B: half-width/full-width spaces versus underscores; C: hyphens versus underscores. Run separately in the same environment.

**Expected result:** Names match after normalization. Company marks follow the ledger environment, PR synchronization is populated, and unnecessary matching-review remarks do not appear.

**Evidence:** Readable log/ledger name differences; UPDATE H, company columns, AB, and AO.

**Note:** The original Markdown records a full-width company-marker example that was not adopted. This case does not assume full-width company markers are supported. If investigated, treat that as a separate requirement/known-limitation check and agree on the expectation before judging the result.

**Execution result / Tester / Date:** __________  **Review:** __________

## 8. Group 5 — Inventory export

Insertion position: **after TC-5-1-3**. Use the lower inventory-export button for all cases.

### TC-5-1-4 — Select files separately for each company using ○ / － / blank

**Source candidate:** A01. Related: the generic version of TC-5-1-3.

**Operation:** Prepare three nonduplicate files and original inventory sheets for companies A/B. Record the actual company codes. Set UPDATE marks as follows, enter the original inventory's full path in C21, and export.

| File | Company A | Company B |
| --- | --- | --- |
| File1 | ○ | － |
| File2 | － | ○ |
| File3 | Blank | ○ |

**Expected result:** CompanyA receives File1 only; companyB receives File2 and File3. Rows marked － or blank are excluded for that company. Data starts at row3. Module information, company code in K, and synchronization in L match the eligible UPDATE rows. Export completes successfully, and the original workbook remains unchanged.

**Evidence:** UPDATE rows, company headers/marks and synchronization; C21; both output sheets; completion message; original-file comparison.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-5 — Merge identical files and combine distinct project names

**Source candidate:** A02.

**Operation:** Prepare three UPDATE rows with identical B:G values. Set H to ProjectA, ProjectB, and ProjectA. Keep I/J and synchronization values the same. Mark all three rows ○ for the target company, confirm its inventory sheet exists, and export.

**Expected result:** One output row is produced. H contains ProjectA and ProjectB on separate lines without repeating ProjectA. A is1, B:G retain the shared information, K contains the company code, and L contains synchronization. Export succeeds and the original workbook remains unchanged.

**Evidence:** Three input rows; company marks and synchronization; single output row; full H contents; completion message.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-6 — Do not merge files whose identifying information differs

**Source candidate:** A03. Related: TC-5-1-5.

**Operation:** Prepare separate conditions with two ○ rows for the target company: A: same filename, different paths; B: same B:E, different sizes; C: same B:F, different timestamps. Export each separately.

**Expected result:** Each execution produces two rows. Different file information is not merged. Numbering is1/2, each output B:G matches its UPDATE row, and the original workbook remains unchanged.

**Evidence:** Input B:G, company marks and synchronization; both output rows; differing cells; completion messages.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-7 — Clear old data, restore formulas, and replace existing output

**Source candidate:** A04. This is a different process from TC-1-1-3.

**Operation:** Prepare an original inventory company sheet with at least five old data rows and the applicable U3/V3 formulas. Export two nonduplicate eligible UPDATE rows. Close the output, reduce UPDATE to one eligible row, and export again using the same original file in C21.

**Expected result:** The first output contains two rows and the second contains one. Old surplus data does not remain. Unneeded A3:T data and lower U/V formulas are cleared. Formulas are restored for current rows with appropriate relative references. If original V3 has no formula, V restoration is not required. The same-name output is updated, and the original remains unchanged.

**Evidence:** Original old-data count and U3/V3 formulas; both UPDATE conditions; output final rows and blank rows below; U/V formulas; messages; original-file comparison.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-8 — Remove company sheets with no eligible files from the output copy

**Source candidate:** A05. This is a different process from TC-3-1-4.

**Operation:** Prepare original inventory sheets for companies A/B, including old data. Keep eligible ○ files for companyA. Set every companyB row to － or blank, then export.

**Expected result:** The output retains companyA and its eligible files, and removes companyB's sheet despite its original old data. CompanyB's sheet remains in the original workbook. This case keeps at least one eligible company; it does not cover saving when all companies have zero files.

**Evidence:** Original A/B sheets and data; UPDATE marks; all output sheet tabs; A's data; B remaining in the original; completion message.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-9 — Do not overwrite an output workbook that is open

**Source candidate:** A06.

**Operation:** Export successfully once. Open the generated output copy in Excel, keep C21 pointing to the original workbook, and export again. Close the output and retry. Optionally test a read-only test output as a separate condition, restoring its attributes afterwards.

**Expected result:** When output is open or unwritable, the tool reports that it is in use or cannot be updated, and no export-completion message appears. Existing output is not deleted or corrupted; the original remains unchanged. Export succeeds after the output is closed and writable.

**Evidence:** Open output's full path; C21; error message; preserved output contents; successful retry. Clearly distinguish the original file from the output copy.

**Execution result / Tester / Date:** __________  **Review:** __________

### TC-5-1-10 — Reject the output copy itself as the input source

**Source candidate:** A07.

**Operation:** Close a previously generated output. Set C21 to that output's full path inside the tool's `棚卸しファイル` folder, then export.

**Expected result:** A notification includes `入力!C21に元の棚卸しファイルを指定してください。出力先のファイル自身は指定できません。` No successful export is reported. The specified output is not deleted or overwritten and retains its contents.

**Evidence:** C21 demonstrating the same input/output path; error message; file existence and contents before and after execution.

**Execution result / Tester / Date:** __________  **Review:** __________

## 9. Existing-case follow-ups — no new numbers

- Correct TC-3-1-3's previously identified Size/TimeStamp evidence inconsistency within its existing evidence sheet. TC-3-1-5 separately verifies revision-specific metadata.
- The “UPDATE sheet exists but contains no data” condition already belongs to TC-5-1-2. Add its evidence to the existing sheet if still missing.
- Keep the accepted ledger-evidence exception for successful TC-4-1-14/22/27. For new competing-candidate/priority tests, capture the relevant ledger rows because they are necessary to establish which candidate should be selected.
- Do not change the previously accepted behavior concerning the output columns used for exclusion reasons.

## 10. Coverage-review cross-reference

| Source candidate | Proposed case |
| --- | --- |
| A01 to A07 | TC-5-1-4 to TC-5-1-10, in the same order |
| A08 | TC-3-1-5 |
| A09 | TC-3-1-6 |
| A10 | TC-4-1-28 |
| A11 | TC-4-1-29 |
| A12 | TC-4-1-30 |
| B01 | TC-4-1-31 |
| B02 | TC-4-1-32 |
| B03 | TC-4-1-33; see its note about full-width company markers |
| B04 | TC-3-1-7 |
| B05 | TC-2-1-6 |
| B06 | TC-2-1-7 |
| B07 | Normal path: TC-1-1-5; error paths: TC-2-1-8 |
| B08 | TC-3-1-8 |
| B09 | TC-3-1-9 |
| B10 | TC-1-1-4 |

There are **23 proposed cases**. Some contain multiple conditions, so 23 executions do not necessarily complete every condition. Select the scope you intend to execute and record results and evidence per condition.
