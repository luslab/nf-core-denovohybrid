////////////////////////////////////////////////////
/* --         LOCAL PARAMETER VALUES           -- */
////////////////////////////////////////////////////

params.summary_params = [:]

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

// Check input path parameters to see if they exist
checkPathParamList = [
    params.input,
    params.reference
]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, "Input samplesheet not specified!" }

def supportedReadTypes = ['nanopore_raw', 'nanopore_corr']
if (!params.long_read_type) {
    exit 1, "No long read type specified! Valid options: ${supportedReadTypes.join(', ')}"
} else {

}

if (!params.start_basecall && !params.start_readqc && !params.assembly && !params.assemblyqc && !params.annotation) { exit 1, "No starting point for the pipeline specified!" }
if (!params.genome_size) { exit 1, "No target genome size specified!"}



////////////////////////////////////////////////////
/* --          CONFIG FILES                    -- */
////////////////////////////////////////////////////

//ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
//ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

// Header files for MultiQC
//ch_pca_header_multiqc        = file("$projectDir/assets/multiqc/deseq2_pca_header.txt", checkIfExists: true)
//ch_clustering_header_multiqc = file("$projectDir/assets/multiqc/deseq2_clustering_header.txt", checkIfExists: true)
//ch_biotypes_header_multiqc   = file("$projectDir/assets/multiqc/biotypes_header.txt", checkIfExists: true)


////////////////////////////////////////////////////
/* --    IMPORT LOCAL MODULES/SUBWORKFLOWS     -- */
////////////////////////////////////////////////////

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
def modules = params.modules.clone()

//def multiqc_options   = modules['multiqc']
//multiqc_options.args += params.multiqc_title ? " --title \"$params.multiqc_title\"" : ''

// other local modules and subworkflows go here

include { GET_SOFTWARE_VERSIONS              } from './modules/local/process/get_software_versions'       addParams( options: [publish_files : ['csv':'']]                                )

/*
 * SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
 */


////////////////////////////////////////////////////
/* --    IMPORT NF-CORE MODULES/SUBWORKFLOWS   -- */
////////////////////////////////////////////////////

/*
 * MODULE: Installed directly from nf-core/modules
 */


/*
 * SUBWORKFLOW: Consisting entirely of nf-core/modules
 */

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

// Info required for completion email and summary
//def multiqc_report      = []
//def pass_percent_mapped = [:]
//def fail_percent_mapped = [:]

workflow DENOVOHYBRID {
    /*
     * MODULE: Pipeline reporting
     */
    GET_SOFTWARE_VERSIONS (
        ch_software_versions.map { it }.collect()
    )

    BASECALL (

    )

    /*
     * MultiQC
     */
    if (!params.skip_multiqc) {
        workflow_summary    = Schema.params_summary_multiqc(workflow, params.summary_params)
        ch_workflow_summary = Channel.value(workflow_summary)

        MULTIQC (
            ch_multiqc_config,
            ch_multiqc_custom_config.collect().ifEmpty([]),
            GET_SOFTWARE_VERSIONS.out.yaml.collect(),
            ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'),
        )
        multiqc_report = MULTIQC.out.report.toList()
    }
}

////////////////////////////////////////////////////
/* --              COMPLETION EMAIL            -- */
////////////////////////////////////////////////////

workflow.onComplete {
    Completion.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    Completion.summary(workflow, params, log)
}

////////////////////////////////////////////////////
/* --                  THE END                 -- */
////////////////////////////////////////////////////
