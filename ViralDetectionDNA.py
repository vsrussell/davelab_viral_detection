from Modules import Module

# Module created using CC_module_helper.py
class ViralDetectionDNA(Module):
    def __init__(self, module_id, is_docker=False):
        super(ViralDetectionDNA, self).__init__(module_id, is_docker)
        # Add output keys here if needed
        self.output_keys = ["paired_viral_dna_sam", "idxstats"]


    def define_input(self):
        # Module creator needs to define which arguments have is_resource=True
        # Module creator needs to rename arguments as required by CC
        self.add_argument("dna_bam",                     is_required=True)
        self.add_argument("sample_id",                  is_required=True)
        self.add_argument("nr_cpus",                    default_value=8)
        self.add_argument("mem",                        default_value=20.0)
        self.add_argument("f",                          default_value=4)
        self.add_argument("F",                          default_value=1024)


    def define_output(self):
        # Module creator needs to define what the outputs are
        # based on the output keys provided during module creation
        sample_id       = self.get_argument("sample_id")
        paired_viral_dna_sam  = self.generate_unique_file_name(sample_id+"_viral_dna_paired_Aligned.out.sam")
        idxstats = self.generate_unique_file_name(sample_id+"_viral_dna_paired_idxstats.txt")

        #log_file        
        self.add_output("paired_viral_dna_sam",       paired_viral_dna_sam)
        self.add_output("idxstats",               idxstats)


    def define_command(self):
        # Module creator needs to use renamed arguments as required by CC
        bam                     = self.get_argument("dna_bam")
        ref_masked_viral          = "/usr/local/bin/masked_viral_genomes_idx_BWA"
        nr_cpus                 = self.get_argument("nr_cpus")
        f                       = self.get_argument("f")
        F                       = self.get_argument("F")

        # get output
        paired_prefix                  = str(self.get_output("paired_viral_dna_sam")).replace("_aligned.sam", "")

        # add module
        cmd = "bash /usr/local/bin/viral_detection_dna.sh"

        # add arguments
        cmd += " {0} {1} {2} {3} {4} {5}".format(
            bam, ref_masked_viral, nr_cpus,
            f, F, paired_prefix)

        # add logging verbosity
        cmd += " !LOG3!"

        return cmd