🕵️ Forensic Analysis Automation Script

🔍 Overview  
A Bash script designed to automate digital forensic investigations on Kali Linux. It integrates tools like Volatility, Binwalk, Bulk Extractor, and Foremost to extract, analyze, and report data from memory dumps, executables, and disk images.

🚀 Features  
1. Auto-Install Tools: Ensures all required tools are available.  
2. Memory Dump Analysis: Uses Volatility to examine RAM dumps.  
3. Data Carving: Leverages Binwalk, Bulk Extractor, and Foremost.  
4. String Extraction: Analyzes .exe files for readable strings.  
5. Report Generation: Produces a final summary and ZIP archive of findings.  
6. Organized Output: Sorts results into structured directories.

⚙️ Requirements  
- OS: Kali Linux  
- Privileges: Root  
- Tools:  
  - volatility  
  - binwalk  
  - bulk_extractor  
  - foremost

📁 Workflow Summary  
1. Checks for root access.  
2. Prompts user to select a file.  
3. Installs missing forensic tools.  
4. Performs:  
   - Data carving  
   - Memory analysis  
   - String extraction  
5. Generates:  
   - Structured directories  
   - Final report (`results_report.txt`)  
   - Zipped archive (`forensic_YYYY-MM-DD_HH-MM-SS.zip`)

🔍 Overview  
A Bash script designed to automate digital forensic investigations on Kali Linux. It integrates tools like Volatility, Binwalk, Bulk Extractor, and Foremost to extract, analyze, and report data from memory dumps, executables, and disk images.

🚀 Features  
1. Auto-Install Tools: Ensures all required tools are available.  
2. Memory Dump Analysis: Uses Volatility to examine RAM dumps.  
3. Data Carving: Leverages Binwalk, Bulk Extractor, and Foremost.  
4. String Extraction: Analyzes .exe files for readable strings.  
5. Report Generation: Produces a final summary and ZIP archive of findings.  
6. Organized Output: Sorts results into structured directories.

⚙️ Requirements  
- OS: Kali Linux  
- Privileges: Root  
- Tools:  
  - volatility  
  - binwalk  
  - bulk_extractor  
  - foremost

📁 Workflow Summary  
1. Checks for root access.  
2. Prompts user to select a file.  
3. Installs missing forensic tools.  
4. Performs:  
   - Data carving  
   - Memory analysis  
   - String extraction  
5. Generates:  
   - Structured directories  
   - Final report (`results_report.txt`)  
   - Zipped archive (`forensic_YYYY-MM-DD_HH-MM-SS.zip`)
