import xlrd
import re
import os
import sys
import math

def nullUp2Valid(p_sheet,p_row,p_col):
    if(p_sheet.cell(p_row,p_col).ctype!=0):
        return p_sheet.cell(p_row,p_col).value
    else:
        return nullUp2Valid(p_sheet,p_row-1,p_col)

def getValueCol(p_sheet,p_value):
    for row in range (p_sheet.nrows):
        for col in range (p_sheet.ncols):
            if(p_sheet.cell(row,col).value==p_value):
                return col

def bit2width(var1):
    if(":" in var1):
        var1=var1.replace('[','')
        var1=var1.replace(']','')
        var1=var1.split(':')
        var1=int(var1[0])-int(var1[1])+1       
        return var1
    else:
        return 1

def width2bus(var1):
    if(var1==1):
        return ''
    else:
        return '['+str(var1-1)+':0]'

def bus_width(var1):
    var1=bit2width(var1)
    var1=width2bus(var1)
    return var1

#def wr_block
def wr_block(p_reg,p_fld,p_rst,p_bit):
    wr_str=[]
    wr_str.append("\nalways@(posedge clk) begin\n")
    wr_str.append("    if(!rst_n) begin\n")
    wr_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    wr_str.append("    end\n")
    wr_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    wr_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    wr_str.append("    end\n")
    wr_str.append("end\n")
    return wr_str

#def wrc_block
def wrc_block(p_reg,p_fld,p_rst,p_bit):
    wrc_str=[]
    wrc_str.append("\nalways@(posedge clk) begin\n")
    wrc_str.append("    if(!rst_n) begin\n")
    wrc_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    wrc_str.append("    end\n")
    wrc_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    wrc_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    wrc_str.append("    end\n")
    wrc_str.append("    else if(%s_wrc_clr) begin\n"%(p_fld.lower()))
    wrc_str.append("        %s <= %s_wrc_clr_val;\n"%(p_fld,p_fld))
    wrc_str.append("    end\n")
    wrc_str.append("end\n")
    return wrc_str

#def wrs_block
def wrs_block(p_reg,p_fld,p_rst,p_bit):
    wrs_str=[]
    wrs_str.append("\nalways@(posedge clk) begin\n")
    wrs_str.append("    if(!rst_n) begin\n")
    wrs_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    wrs_str.append("    end\n")
    wrs_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    wrs_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    wrs_str.append("    end\n")
    wrs_str.append("    else if(%s_wrs_set) begin\n"%(p_fld.lower()))
    wrs_str.append("        %s <= %s_wrs_set_val;\n"%(p_fld,p_fld))
    wrs_str.append("    end\n")
    wrs_str.append("end\n")
    return wrs_str
   
#def wo_block
def wo_block(p_reg,p_fld,p_rst,p_bit):
    wo_str=[]
    wo_str.append("\nalways@(posedge clk) begin\n")
    wo_str.append("    if(!rst_n) begin\n")
    wo_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    wo_str.append("    end\n")
    wo_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    wo_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    wo_str.append("    end\n")
    wo_str.append("end\n")
    return wo_str

#def w1_block
def w1_block(p_reg,p_fld,p_rst,p_bit):
    w1_str=[]
    w1_str.append("\nalways@(posedge clk) begin\n")
    w1_str.append("    if(!rst_n) begin\n")
    w1_str.append("        %s_w1_done <= 1'b0;\n"%(p_fld))
    w1_str.append("    end\n")
    w1_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    w1_str.append("        %s_w1_done <= 1'b1;\n"%(p_fld))
    w1_str.append("    end\n")
    w1_str.append("end\n")
    w1_str.append("\nalways@(posedge clk) begin\n")
    w1_str.append("    if(!rst_n) begin\n")
    w1_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    w1_str.append("    end\n")
    w1_str.append("    else if(%s_wr && (!%s_w1_done)) begin\n"%(p_reg.lower(),p_fld.lower()))
    w1_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    w1_str.append("    end\n")
    w1_str.append("end\n")
    return w1_str

#def wo1_block
def wo1_block(p_reg,p_fld,p_rst,p_bit):
    wo1_str=[]
    wo1_str.append("\nalways@(posedge clk) begin\n")
    wo1_str.append("    if(!rst_n) begin\n")
    wo1_str.append("        %s_wo1_done <= 1'b0;\n"%(p_fld))
    wo1_str.append("    end\n")
    wo1_str.append("    else if(%s_wr) begin\n"%(p_reg.lower()))
    wo1_str.append("        %s_wo1_done <= 1'b1;\n"%(p_fld))
    wo1_str.append("    end\n")
    wo1_str.append("end\n")
    wo1_str.append("\nalways@(posedge clk) begin\n")
    wo1_str.append("    if(!rst_n) begin\n")
    wo1_str.append("        %s <= %s'%s;\n"%(p_fld,bit2width(p_bit),p_rst))
    wo1_str.append("    end\n")
    wo1_str.append("    else if(%s_wr && (!%s_wo1_done)) begin\n"%(p_reg.lower(),p_fld.lower()))
    wo1_str.append("        %s <= pwdata%s;\n"%(p_fld,p_bit))
    wo1_str.append("    end\n")
    wo1_str.append("end\n")
    return wo1_str

def rd_block(p_reg,p_address):
    rd_str=[]
    p_address = p_address.replace('0x','8\'h').replace('0X','8\'h')
    rd_str.append("%8s%s : prdata = %-10s;\n"%('',p_address,p_reg.upper()))
    return rd_str


#  int_logic   
def int_logic(p_sheet):
    int_str = []
    fld_col = getValueCol(p_sheet,'FieldName')
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        if(fld_name.endswith('_int')):
                int_str.append(" | (%s & %s_en)"%(fld_name,fld_name))
    return int_str

#  gen_reg_hdl 
def gen_reg_hdl(p_sheet,ModuleName):
    base_col = getValueCol(p_sheet,'BaseAddress')
    base_value = p_sheet.cell(1,base_col).value.replace('0x','32\'h').replace('0X','32\'h')

    width_col = getValueCol(p_sheet,'Width')
    width_value = int(p_sheet.cell(1,width_col).value)
    data_bus_width = width2bus(width_value)
    
    reg_col = getValueCol(p_sheet,'RegName')
    fld_col = getValueCol(p_sheet,'FieldName')
    rst_col = getValueCol(p_sheet,'ResetValue')
    bit_col = getValueCol(p_sheet,'Bits')
    access_col  = getValueCol(p_sheet,'Access')
    adr_col  = getValueCol(p_sheet,'OffsetAddress')

    fo=open("%s_cfg.v"%(ModuleName),"w")
    fo.write("module %s_cfg ("%(ModuleName))
    fo.write("\n"+16*" "+" clk")
    fo.write("\n"+16*" "+",rst_n")
    fo.write("\n"+16*" "+",pwrite")
    fo.write("\n"+16*" "+",psel")
    fo.write("\n"+16*" "+",penable")
    fo.write("\n"+16*" "+",paddr")
    fo.write("\n"+16*" "+",pwdata")
    fo.write("\n"+16*" "+",prdata")

    as_is_list = ['RW','WRC','WRS','WO','W1','WO1']
    
    w1c_list =['W1C','W1CRS']
    w0c_list =['W0C','W0CRS']
    w1s_list =['W1S','W1SRC']
    w0s_list =['W0S','W0SRC']
    w1t_list =['W1T']
    w0t_list =['W0T']

    wc_list = ['WC','WCRS','WOC']
    ws_list = ['WS','WSRC','WOS']
    rc_list = ['RC','WRC','WSRC','W1SRC','W0SRC']
    rs_list = ['RS','WRS','WCRS','W1CRS','W0CRS']

    
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_name.lower() != 'reserved'):
            if(fld_type in as_is_list):
                fo.write("\n"+16*" "+","+fld_name)
            else:
                fo.write("\n"+16*" "+","+fld_name)

            if(fld_type in w1c_list):
                fo.write("\n"+16*" "+",%s_%s_clr"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_clr_val"%(fld_name,fld_type.lower()))
            if(fld_type in w0c_list):
                fo.write("\n"+16*" "+",%s_%s_clr"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_clr_val"%(fld_name,fld_type.lower()))
            if(fld_type in w1s_list):
                fo.write("\n"+16*" "+",%s_%s_set"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_set_val"%(fld_name,fld_type.lower()))
            if(fld_type in w0s_list):
                fo.write("\n"+16*" "+",%s_%s_set"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_set_val"%(fld_name,fld_type.lower()))
            if(fld_type in w1t_list):
                fo.write("\n"+16*" "+",%s_%s_tog"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_tog_val"%(fld_name,fld_type.lower()))
            if(fld_type in w0t_list):
                fo.write("\n"+16*" "+",%s_%s_tog"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_tog_val"%(fld_name,fld_type.lower()))
            if(fld_type in wc_list):
                fo.write("\n"+16*" "+",%s_%s_clr"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_clr_val"%(fld_name,fld_type.lower()))
            if(fld_type in rc_list and fld_type != 'WRC'):
                fo.write("\n"+16*" "+",%s_%s_clr"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_clr_val"%(fld_name,fld_type.lower()))
            if(fld_type in ws_list):
                fo.write("\n"+16*" "+",%s_%s_set"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_set_val"%(fld_name,fld_type.lower()))
            if(fld_type in rs_list and fld_type != 'WRS'):
                fo.write("\n"+16*" "+",%s_%s_set"%(fld_name,fld_type.lower()))
                fo.write("\n"+16*" "+",%s_%s_set_val"%(fld_name,fld_type.lower()))
    fo.write("\n"+16*" "+");")
    fo.write("\n")
    
    #signal direction declare
    fo.write("input           clk;\n")
    fo.write("input           rst_n;\n")
    fo.write("input           pwrite;\n")
    fo.write("input           psel;\n")    
    fo.write("input           penable;\n")    
    fo.write("input  [31:0]   paddr;\n")
    fo.write("input  %-9s%s;\n"%(data_bus_width,'pwdata'))
    fo.write("output %-9s%s;\n"%(data_bus_width,'prdata'))
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        bit       = p_sheet.cell(row,bit_col).value
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_name.lower() != 'reserved'):
            if(fld_type in as_is_list):
                fo.write("output %-9s%s;\n"%(bus_width(bit),fld_name))
            else:
                fo.write("input  %-9s%s;\n"%(bus_width(bit),fld_name))
            
            if(fld_type in w1c_list):
                fo.write("output %-9s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0c_list):
                fo.write("output %-9s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w1s_list):
                fo.write("output %-9s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0s_list):
                fo.write("output %-9s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w1t_list):
                fo.write("output %-9s%s_%s_tog;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_tog_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0t_list):
                fo.write("output %-9s%s_%s_tog;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_tog_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in wc_list):
                fo.write("output %-9s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in rc_list and fld_type != 'WRC'):
                fo.write("output %-9s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in ws_list):
                fo.write("output %-9s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in rs_list and fld_type != 'WRS'):
                fo.write("output %-9s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("output %-9s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
                     
     #signal type declare
    fo.write("\nwire            clk;\n")
    fo.write("wire            rst_n;\n")
    fo.write("wire            pwrite;\n")
    fo.write("wire            psel;\n")    
    fo.write("wire            penable;\n")    
    fo.write("wire [31:0]     paddr;\n")    
    fo.write("wire %-11s%s;\n"%(data_bus_width,'pwdata'))
    fo.write("reg  %-11s%s;\n"%(data_bus_width,'prdata'))
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        bit       = p_sheet.cell(row,bit_col).value
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_name.lower() != 'reserved'):
            if(fld_type in as_is_list):
                fo.write("reg  %-11s%s;\n"%(bus_width(bit),fld_name))
            else:
                fo.write("wire %-11s%s;\n"%(bus_width(bit),fld_name))
            if(fld_type in w1c_list):
                fo.write("wire %-11s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0c_list):
                fo.write("wire %-11s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w1s_list):
                fo.write("wire %-11s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0s_list):
                fo.write("wire %-11s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w1t_list):
                fo.write("wire %-11s%s_%s_tog;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_tog_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in w0t_list):
                fo.write("wire %-11s%s_%s_tog;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_tog_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in wc_list):
                fo.write("wire %-11s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in rc_list):
                fo.write("wire %-11s%s_%s_clr;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_clr_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in ws_list):
                fo.write("wire %-11s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
            if(fld_type in rs_list):
                fo.write("wire %-11s%s_%s_set;\n"%('',fld_name,fld_type.lower()))
                fo.write("wire %-11s%s_%s_set_val;\n"%(bus_width(bit),fld_name,fld_type.lower()))
    
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_type == 'W1'):
            fo.write("reg  %-11s%s_w1_done;\n"%('',fld_name))
        if(fld_type == 'WO1'):
            fo.write("reg  %-11s%s_wo1_done;\n"%('',fld_name))

    #reg_declared
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        if(p_sheet.cell(row,adr_col).value!=''):
            fo.write("wire %-11s%s;\n"%(data_bus_width,reg_name.upper()))
            
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(p_sheet.cell(row,adr_col).value!=''):
            fo.write("wire %-11s%s_wr;\n"%('',reg_name.lower()))
            fo.write("wire %-11s%s_rd;\n"%('',reg_name.lower()))

    #insert apb-->reg_wr,reg_rd.
    fo.write("wire %-11sreg_wr;\n"%(''))
    fo.write("wire %-11sreg_rd;\n"%(''))
    fo.write("wire %-11sapb_wr_en;\n"%(''))
    fo.write("wire %-11sapb_rd_en;\n"%(''))
    fo.write("\nassign reg_wr = psel & pwrite & penable;\n")
    fo.write("assign reg_rd = psel & (~pwrite) & (~penable);\n")
    
    wr_en = 'assign apb_wr_en = '
    rd_en = 'assign apb_rd_en = '
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        address = nullUp2Valid(p_sheet,row,adr_col).replace('0x','8\'h').replace('0X','8\'h')
        if(p_sheet.cell(row,adr_col).value!=''):
            fo.write("assign %s_wr = (paddr == %s) & reg_wr;\n"%(reg_name.lower(),base_value+' + '+address))
            fo.write("assign %s_rd = (paddr == %s) & reg_rd;\n"%(reg_name.lower(),base_value+' + '+address))
            wr_en = wr_en + reg_name.lower() + '_wr' + ' | '
            rd_en = rd_en + reg_name.lower() + '_rd' + ' | '
    wr_en = wr_en[:-3] + ';'
    rd_en = rd_en[:-3] + ';'
    fo.write("%s\n"%wr_en)
    fo.write("%s\n\n"%rd_en)
  

    fo.write("\n//regs defination\n")
    #assign REG[1]=fld
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        rst_value = p_sheet.cell(row,rst_col).value
        rst_value = re.search('[bodh][a-f0-9]+$',rst_value).group()
        bit       = p_sheet.cell(row,bit_col).value
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_name.lower() == 'reserved' or fld_type == 'WO' or fld_type == 'WOC' or fld_type == 'WOS' or fld_type == 'WO1'):
            fo.write("assign %s%s = %s\'%s;\n"%(reg_name.upper(),bit,bit2width(bit),rst_value))
        else:
            fo.write("assign %s%s = %s;\n"%(reg_name.upper(),bit,fld_name))
    #main logic for w1c
    for row in range (p_sheet.nrows)[1:]:
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        bit       = p_sheet.cell(row,bit_col).value
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        if(fld_name.lower() != 'reserved'):
            if(fld_type in w1c_list):
                fo.write("assign %s_%s_clr = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_clr_val%s =%s%s &(~pwdata%s);\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            if(fld_type in w0c_list):
                fo.write("assign %s_%s_clr = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_clr_val%s =%s%s & pwdata%s;\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            if(fld_type in w1s_list):
                fo.write("assign %s_%s_set = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_set_val%s =%s%s | pwdata%s;\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            if(fld_type in w0s_list):
                fo.write("assign %s_%s_set = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_set_val%s =%s%s |(~pwdata%s);\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            if(fld_type in w1t_list):
                fo.write("assign %s_%s_tog = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_tog_val%s =%s%s ^ pwdata%s;\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            if(fld_type in w0t_list):
                fo.write("assign %s_%s_tog = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_tog_val%s =%s%s ^(~pwdata%s);\n"%(fld_name,fld_type.lower(),bus_width(bit),fld_name,bus_width(bit),bit))
            
            if(fld_type in wc_list):
                fo.write("assign %s_%s_clr = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_clr_val%s =%s'b0;\n"%(fld_name,fld_type.lower(),bus_width(bit),bit2width(bit)))
            if(fld_type in rc_list):
                fo.write("assign %s_%s_clr = %s_rd;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_clr_val%s =%s'b0;\n"%(fld_name,fld_type.lower(),bus_width(bit),bit2width(bit)))
            if(fld_type in ws_list):
                fo.write("assign %s_%s_set = %s_wr;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_set_val%s =%s'b%s;\n"%(fld_name,fld_type.lower(),bus_width(bit),bit2width(bit),pow(2,bit2width(bit))-1))
            if(fld_type in rs_list):
                fo.write("assign %s_%s_set = %s_rd;\n"%(fld_name,fld_type.lower(),reg_name.lower()))
                fo.write("assign %s_%s_set_val%s =%s'b%s;\n"%(fld_name,fld_type.lower(),bus_width(bit),bit2width(bit),pow(2,bit2width(bit))-1))

    fo.write("\n//write regs")
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        fld_name  = p_sheet.cell(row,fld_col).value.lower()
        rst_value = p_sheet.cell(row,rst_col).value
        rst_value = re.search('[bodh][a-f0-9]+$',rst_value).group()
        bit       = p_sheet.cell(row,bit_col).value
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        if(fld_name.lower() != 'reserved'):
            if(fld_type == 'RW'): 
                fo.write("".join(wr_block(reg_name,fld_name,rst_value,bit)))
            if(fld_type == 'WRC'): 
                fo.write("".join(wrc_block(reg_name,fld_name,rst_value,bit)))
            if(fld_type == 'WRS'): 
                fo.write("".join(wrs_block(reg_name,fld_name,rst_value,bit)))
            if(fld_type == 'WO'): 
                fo.write("".join(wo_block(reg_name,fld_name,rst_value,bit)))
            if(fld_type == 'W1'): 
                fo.write("".join(w1_block(reg_name,fld_name,rst_value,bit)))
            if(fld_type == 'WO1'): 
                fo.write("".join(wo1_block(reg_name,fld_name,rst_value,bit)))

    fo.write("\n//read regs\n")
    fo.write("always@(posedge clk) begin\n")
    fo.write("    if(!rst_n) begin\n")
    fo.write("        prdata <= 32'b0;\n")
    fo.write("    end\n")
    fo.write("    else if (apb_rd_en) begin\n")
    fo.write("        case(paddr)\n")
    for row in range (p_sheet.nrows)[1:]:
        reg_name  = nullUp2Valid(p_sheet,row,reg_col)
        fld_type  = nullUp2Valid(p_sheet,row,access_col)
        address = nullUp2Valid(p_sheet,row,adr_col).replace('0x','8\'h').replace('0X','8\'h')
        if(p_sheet.cell(row,adr_col).value!=''):
            fo.write("".join(rd_block(reg_name,base_value+' + '+address)))
    fo.write("        default:prdata = %s'b0;\n"%(width_value))
    fo.write("        endcase\n")
    fo.write("    end\n")
    fo.write("end\n")
    fo.write("endmodule")
    fo.close()
    print("Successfully generated %s_cfg.v"%(ModuleName))

if(len(sys.argv) < 2):
    print("[Error]:Not have input file")
    print("Usage : %s <filename>.xlsx"%(sys.argv[0]))
    sys.exit(1)

if(sys.argv[1]=='-help'):
    print("Usage : %s <filename>.xlsx"%(sys.argv[0]))
    sys.exit(0)

if(os.path.exists(sys.argv[1])==False):
    print("[Error]:Not such file")
    sys.exit(1)

book = xlrd.open_workbook(sys.argv[1])
sheets_num = len(book.sheet_names())
for index in range (sheets_num):
    sheet0 = book.sheet_by_index(index)
    ModuleName = sheet0.name
    gen_reg_hdl(sheet0,ModuleName)
sys.exit(0)

