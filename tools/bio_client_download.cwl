cwlVersion: v1.0
class: CommandLineTool
id: bio_client_download
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-client:{{ bio_client }}"
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (inputs.file_size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.file_size / 1048576))
    outdirMin: $(Math.ceil (inputs.file_size / 1048576))
    outdirMax: $(Math.ceil (inputs.file_size / 1048576))
  - class: EnvVarRequirement
    envDef:
    - envName: "REQUESTS_CA_BUNDLE"
      envValue: $(inputs.cert.path)

inputs:
  cert:
      type: File
      default:
        class: File
        location: /etc/pki/tls/certs/ca-bundle.crt

  config_file:
    type: File
    inputBinding:
      prefix: -c
      position: 0

  dir_path:
    type: string
    default: "."
    inputBinding:
      prefix: --dir_path
      position: 99

  download:
    type: string
    default: download
    inputBinding:
      position: 1

  download_handle:
    type: string
    inputBinding:
      position: 98

  file_size:
    type: long
    default: 1

outputs:
  output:
    type: File
    outputBinding:
      glob: "*"

baseCommand: [/usr/local/bin/bio_client.py]
