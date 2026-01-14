# DOCX

Word document creation and editing with tracked changes, comments, and formatting.

## When to Use

Use this skill when:
- Creating or editing Word (.docx) documents
- Working with tracked changes and redlining
- Adding comments and annotations
- Generating legal or professional documents
- Creating reports, proposals, contracts
- Mail merge and document automation
- Converting between document formats

## Key Concepts

### Document Structure
- Paragraphs, runs, and text formatting
- Tables with headers, rows, and cells
- Headers, footers, and page numbers
- Sections and page breaks
- Styles (paragraph, character, list)
- Images, shapes, and smart art

### Collaboration Features
- **Tracked Changes**: Track insertions, deletions, formatting
- **Comments**: Add inline comments and replies
- **Review Mode**: Accept/reject changes
- **Compare Documents**: Show differences between versions

### Advanced Features
- Tables of contents and indexes
- Cross-references and bookmarks
- Fields and dynamic content
- Mail merge templates
- Document protection and permissions
- Digital signatures

## Common Tools

### Python
- **python-docx**: Create and modify .docx files
- **docxcompose**: Merge multiple documents
- **docx2txt**: Extract text from documents

### Node.js
- **docx**: Create .docx documents
- **docxtemplater**: Template-based generation

### CLI Tools
- **pandoc**: Universal document converter
- **unoconv**: LibreOffice-based conversion
- **LibreOffice Headless**: Full document processing

## Patterns and Practices

### Document Creation Workflow
1. Define document structure (headers, sections)
2. Create or load template
3. Add content with proper formatting
4. Insert tables and visual elements
5. Add cross-references and TOC
6. Enable tracking if collaborative
7. Review and validate
8. Export final version

### Legal/Professional Documents
- Use consistent styling
- Enable track changes from start
- Add clear comments for reviewers
- Number pages and sections
- Include revision history
- Protect formatting with styles
- Convert to PDF for final delivery

### Best Practices
- Use styles for consistent formatting
- Avoid direct formatting when possible
- Define templates for recurring documents
- Test mail merge fields
- Validate images and embedded objects
- Check accessibility (alt text, fonts)
- Version control source documents

## Document Operations

### Python Example
```python
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

# Create document
doc = Document()

# Add heading
doc.add_heading('Project Report', level=1)

# Add paragraph with formatting
p = doc.add_paragraph()
p.add_run('Bold text').bold = True
p.add_run(' and regular text.')

# Add table
table = doc.add_table(rows=3, cols=3)
table.style = 'Table Grid'

# Add image
doc.add_picture('chart.png', width=Inches(4.0))

# Save
doc.save('report.docx')

# Load existing
doc = Document('existing.docx')
```

### Node.js Example
```javascript
const { Document, Packer, Paragraph, TextRun } = require('docx');

const doc = new Document({
  sections: [{
    properties: {},
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text: "Hello World",
            bold: true
          })
        ]
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("hello.docx", buffer);
});
```

## File Patterns

- `**/*.docx`
- `**/*.doc`
- `**/*.dotx` (templates)
- `**/templates/**/*.{docx,dotx}`

## Keywords

Word, DOCX, document, tracked changes, comments, redlining, report, contract, proposal, legal document, mail merge, document automation, formatting, styles, table of contents
