module.exports = {
  basedir: process.cwd(),
  dest: 'generated/README.pdf',
  stylesheet: ['.github/readme-pdf.css'],
  body_class: ['markdown-body'],
  marked_options: {
    gfm: true,
  },
  pdf_options: {
    format: 'A4',
    margin: '14mm 12mm 18mm',
    printBackground: true,
    displayHeaderFooter: true,
    footerTemplate: `
      <style>
        .footer {
          width: 100%;
          color: #57606a;
          font: 8px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
          text-align: center;
        }
      </style>
      <div class="footer">
        Generated from README.md · Page <span class="pageNumber"></span> of <span class="totalPages"></span>
      </div>
    `,
  },
  launch_options: {
    args: ['--no-sandbox'],
  },
};
