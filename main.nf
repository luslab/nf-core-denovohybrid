#!/usr/bin/env nextflow
/*
========================================================================================
                         nf-core/denovohybrid
========================================================================================
 nf-core/denovohybrid Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/nf-core/denovohybrid
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --               PRINT HELP                 -- */
////////////////////////////////////////////////////

def json_schema = "$projectDir/nextflow_schema.json"
if (params.help) {
    // TODO nf-core: Update typical command used to run pipeline
    def command = "nextflow run nf-core/denovohybrid --input samplesheet.csv -profile docker"
    log.info Schema.params_help(workflow, params, json_schema, command)
    exit 0
}

////////////////////////////////////////////////////
/* --          INPUT FILE PARAMETERS           -- */
////////////////////////////////////////////////////

params.reference         = Checks.get_genome_attribute(params, 'reference')

////////////////////////////////////////////////////
/* --         PRINT PARAMETER SUMMARY          -- */
////////////////////////////////////////////////////

def summary_params = Schema.params_summary_map(workflow, params, json_schema)
log.info Schema.params_summary_log(workflow, params, json_schema)

////////////////////////////////////////////////////
/* --          PARAMETER CHECKS                -- */
////////////////////////////////////////////////////

// Check that conda channels are set-up correctly
if (params.enable_conda) {
    Checks.check_conda_channels(log)
}

// Check AWS batch settings
Checks.aws_batch(workflow, params)

// Check the hostnames against configured profiles
Checks.hostname(workflow, params, log)

// Check genome key exists if provided
Checks.genome_exists(params, log)

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow DENOVOHYBRID {
    /*
     * SUBWORKFLOW: Run main nf-core/denovohybrid analysis pipeline
     */
    include { DENOVOHYBRID } from './denovohybrid' addParams( summary_params: summary_params )
    DENOVOHYBRID ()
}


////////////////////////////////////////////////////
/* --                  THE END                 -- */
////////////////////////////////////////////////////
