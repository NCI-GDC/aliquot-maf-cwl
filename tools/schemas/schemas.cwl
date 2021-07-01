- name: indexed_file
  type: record
  fields:
    - name: main_file_uuid
      type: string
    - name: index_file_uuid
      type: string
- name: optional_file
  type: record
  fields:
    - name: key
      type: string
    - name: file
      type: File
