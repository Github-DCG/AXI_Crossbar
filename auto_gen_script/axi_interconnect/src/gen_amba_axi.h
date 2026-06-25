#ifndef GEN_AMBA_AXI_H
#define GEN_AMBA_AXI_H

extern int gen_axi_amba( unsigned int numM, unsigned int numS, char *module, char *prefix, FILE *fo);
extern int gen_axi_crossbar( unsigned int numM, unsigned int numS, char *prefix, FILE *fo);
extern int gen_axi_m2s( unsigned int num, char *prefix, FILE *fo);
extern int gen_axi_s2m( unsigned int num, char *prefix, FILE *fo);
extern int gen_axi_arbiter_m2s( unsigned int num, char *prefix, FILE *fo);
extern int gen_axi_arbiter_s2m( unsigned int num, char *prefix, FILE *fo);
extern int gen_axi_default_slave( char* prefix, FILE* fo );
extern int gen_rr_fixed_arbiter( char* prefix, FILE* fo );
extern int gen_sid_buffer( char* prefix, FILE* fo );
extern int gen_reorder( char* prefix, FILE* fo );
extern int gen_axi_fifo_sync( char* prefix, FILE* fo );
extern int gen_cross_4k_if( char* prefix, FILE* fo );


#endif
