# Automated README PDF

This repository automatically publishes a PDF version of `README.md`. The PDF is a generated artifact, not a separately maintained resume.

## What happens after a README update

1. You push a change to `README.md` on the `main` branch.
2. GitHub Actions starts the **Generate README PDF** workflow.
3. The workflow installs the pinned `md-to-pdf` renderer (`5.2.5`), which renders the current Markdown through headless Chromium.
4. The renderer applies the repository's local print styles from `.github/readme-pdf.css` and writes the result to `generated/README.pdf`.
5. If the PDF differs from the committed version, the workflow commits and pushes the refreshed file as `github-actions[bot]`.
6. The download badge in `README.md` points to `generated/README.pdf` on `main`, so visitors receive the version generated from the latest committed README.

The visitor does not generate the file at click time. GitHub profile READMEs are static, so the workflow regenerates it after each relevant push instead.

## Files involved

| File | Purpose |
| --- | --- |
| `README.md` | Source content for the PDF and the download badge. |
| `.github/workflows/generate-readme-pdf.yml` | GitHub Action that generates and commits the PDF. |
| `.github/readme-pdf.config.cjs` | PDF renderer settings: output path, A4 size, margins, footer, and Chromium options. |
| `.github/readme-pdf.css` | Local print styles for readable headings, tables, images, code, and page breaks. |
| `generated/README.pdf` | Generated PDF served by the download button. |

## When the workflow runs

It runs automatically when a push to `main` changes any of these files:

- `README.md`
- `.github/workflows/generate-readme-pdf.yml`
- `.github/readme-pdf.config.cjs`
- `.github/readme-pdf.css`

It can also be run manually: open the repository's **Actions** tab, select **Generate README PDF**, choose **Run workflow**, and run it on `main`.

## First-time setup and permissions

The workflow requests `contents: write` permission so it can commit `generated/README.pdf` back to this repository. If the commit step reports a permission error:

1. Open **Settings → Actions → General** in the repository.
2. Under **Workflow permissions**, allow **Read and write permissions**.
3. Save the setting and rerun the workflow from the **Actions** tab.

GitHub Actions must also be enabled for the repository.

## Normal update process

1. Edit and commit `README.md` as usual.
2. Push the commit to `main`.
3. Wait for the **Generate README PDF** workflow to finish successfully.
4. The bot commits the refreshed `generated/README.pdf`.
5. Open the README download badge to verify the latest PDF.

No manual PDF editing or uploading is required.

## Customising the output

- Change `.github/readme-pdf.css` to adjust the PDF appearance.
- Change `.github/readme-pdf.config.cjs` to adjust paper size, margins, footer text, or renderer options.
- Keep the output path as `generated/README.pdf` unless you also update the README download link and the workflow's commit path.

Changes to either print configuration file trigger a fresh PDF build on the next push to `main`.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| The PDF is missing | Run the workflow once manually after this setup is merged. The first successful run creates `generated/README.pdf`. |
| The download shows an older PDF | Confirm the latest **Generate README PDF** workflow completed and that its bot commit is on `main`. |
| The workflow cannot push | Enable read/write workflow permissions as described above. |
| An external badge or image is missing | The source service may be unavailable while the runner renders the PDF; rerun the workflow after the service recovers. |
| You changed another branch | Automatic generation is intentionally limited to `main`; merge the change into `main` or run the workflow manually on that branch. |

## Why the workflow does not loop forever

The trigger watches the README and PDF-generation configuration files, not `generated/README.pdf`. The bot's commit therefore does not start another PDF-generation run.
