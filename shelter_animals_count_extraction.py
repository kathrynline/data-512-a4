from tableauscraper import TableauScraper as TS 

url = "https://public.tableau.com/views/Covid-19ImpactDashboard/Covid-19Impact?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Fpublic.tableau.com%2F&:embed_code_version=3&:tabs=no&:toolbar=yes&:animate_transition=yes&:display_static_image=no&:display_spinner=no&:display_overlay=yes&:display_count=yes&:language=en&publish=yes&:loadOrderID=0"

ts = TS()
ts.loads(url)
workbook = ts.getWorkbook()

# I saved all of the raw data directly from the Tableau dashboard. 
for t in workbook.worksheets:
    name = t.name
    name = name.lower().replace(" ", "_")
    data = t.data
    data.to_csv(f"~/Desktop/data-512-a4-data/raw_data/shelter_animals_raw/{name}.csv")
