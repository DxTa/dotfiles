# XLSX

Comprehensive spreadsheet creation, editing, data analysis, and visualization.

## When to Use

Use this skill when:
- Creating or editing Excel (.xlsx) spreadsheets
- Working with formulas, formatting, and data validation
- Analyzing data in spreadsheets
- Generating reports from spreadsheet data
- Creating financial models or budgets
- Visualizing data with charts
- Importing/exporting CSV/TSV data

## Key Concepts

### File Operations
- Create new workbooks and worksheets
- Read and modify existing files
- Merge multiple spreadsheets
- Export data to other formats
- Handle large datasets efficiently

### Data Manipulation
- Cell values, formulas, and formats
- Named ranges and data validation
- Sorting, filtering, and pivot tables
- Data transformation and cleaning
- Conditional formatting
- Data consolidation

### Formulas and Calculations
- Basic arithmetic and math functions
- Statistical functions (SUM, AVERAGE, COUNTIF)
- Lookup functions (VLOOKUP, INDEX/MATCH, XLOOKUP)
- Date and time calculations
- Text manipulation functions
- Array formulas and dynamic arrays

### Visualization
- Column, bar, line, pie, scatter charts
- Pivot tables and pivot charts
- Sparklines and data bars
- Conditional formatting rules
- Custom chart formatting

## Common Tools

### Python
- **openpyxl**: Read/write .xlsx files
- **xlsxwriter**: Create complex files with formatting
- **pandas**: Data analysis with Excel I/O

### Node.js
- **exceljs**: Create, modify, read Excel files
- **xlsx**: Full-featured Excel library

### CLI Tools
- **ssconvert** (Gnumeric): Format conversion
- **csvkit**: CSV to Excel conversion

## Patterns and Practices

### Data Analysis Workflow
1. Import data from source
2. Clean and normalize data
3. Apply transformations and calculations
4. Create pivot tables for summaries
5. Generate visualizations
6. Add formulas and cross-checks
7. Format for readability
8. Export report

### Performance Tips
- Use `read_only=True` for large files
- Batch write operations
- Minimize cell formatting
- Use data tables for structured data
- Optimize formulas (avoid volatile functions)

### Best Practices
- Use named ranges for clarity
- Document formulas in comments
- Separate data from calculations
- Use consistent formatting
- Validate data on input
- Protect critical cells from modification
- Use templates for recurring reports

## File Operations

### Python Example
```python
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill

# Create new workbook
wb = Workbook()
ws = wb.active
ws['A1'] = 'Date'
ws['B1'] = 'Revenue'

# Add formula
ws['C2'] = '=SUM(B2:B10)'

# Save
wb.save('report.xlsx')

# Load existing
wb = load_workbook('existing.xlsx')
ws = wb.active
```

### Node.js Example
```javascript
const ExcelJS = require('exceljs');

const workbook = new ExcelJS.Workbook();
const sheet = workbook.addWorksheet('Sales');

sheet.columns = [
  { header: 'Product', key: 'product' },
  { header: 'Quantity', key: 'quantity' }
];

await workbook.xlsx.writeFile('sales.xlsx');
```

## File Patterns

- `**/*.xlsx`
- `**/*.xls`
- `**/*.xlsm`
- `**/data/**/*.{xlsx,csv,tsv}`

## Keywords

Excel, spreadsheet, xlsx, formula, chart, pivot table, data analysis, data visualization, financial model, report generation, CSV, TSV, data import, data export
