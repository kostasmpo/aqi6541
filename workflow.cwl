cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: main
    label: Air Quality Index Analysis
    doc: Air Quality Index Analysis based on Sentinel-5P data
    requirements: []
    inputs:
      test_all: boolean?
      date_start:
        label: Start date
        doc: Start date for data collection (YYYY-MM-DD)
        type: string
      date_end:
        label: End date
        doc: End date for data collection (YYYY-MM-DD)
        type: string
      aoi:
        label: Area of interest
        doc: Area of interest as a GeoJSON file or string
        type: string
      analysis:
        label: Analysis type
        doc: Type of analysis (Daily, Monthly, Max)
        type: string
        default: "Daily"
      cdse_username:
        label: CDSE Username
        doc: The username for the account to be used to download images from Copernicus Data Space Ecosystem
        type: string
      cdse_password:
        label: CDSE Password
        doc: The password for the account to be used to download images from Copernicus Data Space Ecosystem
        type: string
        
    outputs:
      - id: results
        outputSource:
          - node_analyze/results
        type: Directory

    steps:
      node_analyze:
        run: "#analyze-aqi"
        in:
          date_start: date_start
          date_end: date_end
          aoi: aoi
          analysis: analysis
          cdse_username: cdse_username
          cdse_password: cdse_password
          test_all: test_all
        out:
          - results

          
  - class: CommandLineTool
    id: analyze-aqi
    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 2048
        
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          cdse_username: $(inputs.cdse_username)
          cdse_password: $(inputs.cdse_password)

    hints:
      DockerRequirement:
        dockerPull: aqi_cwl_test:latest
    baseCommand: ["python","/app/app.py"]
    arguments: []

    inputs:
      test_all:
        type: boolean
        inputBinding:
          prefix: --test_all
      date_start:
        type: string
        inputBinding:
          prefix: --date_start
      date_end:
        type: string
        inputBinding:
          prefix: --date_end
      aoi:
        type: string
        inputBinding:
          prefix: --aoi
      analysis:
        type: string
        inputBinding:
          prefix: --analysis
      cdse_username: string
      cdse_password: string

    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .