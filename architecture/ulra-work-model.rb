{
  works: [{
    work: {
      name: "ULRA Application",
      contracts: [{
        name: "For Ingest",
        contracts: [{
          validator: 'Sipity::Contracts::IngestContract'
        }]
      }],
      forms: [{
        form: "Attach",
        contracts: [
          { validates: 'self', validator: 'Sipity::Validators::ValidateAtLeastOneAttachment' },
          { validates: 'attached_files_completion_state', presence: true, inclusion: "ND.attached_files_completion_state/options" }
        ],
        terms: [
          {
            term: 'ND.attached_files_completion_state', label: "I am submitting",
            hint: "You may upload your final version at a later date. However, the final version of your project must be provided before you receive any monetary award."
          },
          { term: 'ND.attachment' },
          { term: 'ND.project_url'}
        ]
      },{
        form: "Plan of Study",
        contracts: [
          { validates: 'ND.expected_graduation_term', presence: true, inclusion: "ND.expected_graduation_term/options" },
          { validates: 'ND.underclass_level', presence: true, inclusion: "ND.underclass_level/options" },
          { validates: 'ND.major', presence: true },
          { validates: 'ND.primary_college', presence: true, cardinality: 1 }
        ],
        terms: [
          { term: 'ND.expected_graduation_term', cardinality: 1 },
          { term: 'ND.underclass_level' },
          { term: 'ND.major', cardinality: 'many' },
          { term: 'ND.minor', cardinality: 'many' },
          { term: 'ND.primary_college', cardinality: 1 }
        ]
      }],
      terms: [{
        term: 'ND.attached_files_completion_state', cardinality: 1,
        label: "Project Files Completion Status",
        options: ['a representative sample of my project', 'the final version of my project'],
      },{
        term: 'ND.attachment', cardinality: 'many',
        label: 'Upload project file(s)',
      },{
        term: 'ND.project_url', cardinality: 1,
        label: 'Project URL',
        hint: 'If you do not have project files to upload, provide a URL to your project.'
      }]
    }
  }],
  terms: [{
    term: 'ND.attachment', hint: "To select multiple files: Windows Ctrl+click; Mac Cmd+click", type: 'Sipity::Models::Attachment'
  }, {
    term: 'ND.underclass_level', options: ['First Year', 'Sophomore', 'Junior', 'Senior', '5th Year'], cardinality: 1
  }]
}
