
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %  
 % Copyright (c) 2017, BigCat Wireless Pvt Ltd
 % All rights reserved.
 % 
 % Redistribution and use in source and binary forms, with or without
 % modification, are permitted provided that the following conditions are met:
 % 
 %     * Redistributions of source code must retain the above copyright notice,
 %       this list of conditions and the following disclaimer.
 %
 %     * Redistributions in binary form must reproduce the above copyright
 %       notice, this list of conditions and the following disclaimer in the
 %       documentation and/or other materials provided with the distribution.
 %
 %     * Neither the name of the copyright holder nor the names of its contributors
 %       may be used to endorse or promote products derived from this software
 %       without specific prior written permission.
 % 
 % 
 % 
 % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 % IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 % DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 % FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 % DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 % SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 % CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 % OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 % OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DUC_LINEUP_param - DSPBA Design Parameters Start
clear DUC_LINEUP_param; 

%%%%%%%%%%% Specify whether to generate Co-efficients or use(load) already existing co-efficient
format long;  
OccupiedBW                              = 0.9;             % Proportion of LTE carrier filled with subcarriers


%% System Parameters
DUC_LINEUP_param.ChanCount              = 1;               % How many data channels
DUC_LINEUP_param.ClockRate              = 491.52;          % The system clock rate in MHz
DUC_LINEUP_param.SampleRate_5MHz        = 7.68;            % The data rate per channel in MSps (mega-samples per second)
DUC_LINEUP_param.SampleRate_10MHz       = 15.36;           % The data rate per channel in MSps (mega-samples per second)
DUC_LINEUP_param.SampleRate_20MHz       = 491.52; 
DUC_LINEUP_param.Base_addr              = 0;

DUC_LINEUP_param.ClockMargin            = 127.0;           % Adjust the pipelining effort
DUC_LINEUP_param.ClockMargin_DPD        = 127;
DUC_LINEUP_param.ClockMargin_CFR        = 127;
DUC_LINEUP_param.ClockMargin_DUC        = 112;

%%%%%%%%%%%%%%%%%%%%% BASE AND SIGNAL FREQ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DUC_LINEUP_param.A1xC1_Freq             = -8;                  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NCO Tunning Frequncy selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


DUC_LINEUP_param.A12xC_NCO.Freq         = [-30 -10 10 30 -30 -10 10 30];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Number of channel selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

DUC_LINEUP_param.SampleRate_A1xC1=DUC_LINEUP_param.SampleRate_20MHz;


%% ModelIP setup
                     
 DUC_LINEUP_param.chan_filter.base_addr1             = DUC_LINEUP_param.Base_addr + 128;                      
 DUC_LINEUP_param.HB_filt4.base_addr1                =  DUC_LINEUP_param.chan_filter.base_addr1 + 128;
 DUC_LINEUP_param.HB_filt5.base_addr1                = DUC_LINEUP_param.HB_filt4.base_addr1 + 128;
 DUC_LINEUP_param.HB_filt5_2.base_addr1              = DUC_LINEUP_param.HB_filt5.base_addr1 + 128;
 DUC_LINEUP_param.A12xC_NCO.base_addr                = DUC_LINEUP_param.HB_filt5_2.base_addr1 + 128;
 DUC_LINEUP_param.A12xC_NCO.Sync                     = DUC_LINEUP_param.A12xC_NCO.base_addr + 128;
 DUC_LINEUP_param.HB_filt6.base_addr1                = DUC_LINEUP_param.A12xC_NCO.Sync + 16;
 DUC_LINEUP_param.HB_filt7.base_addr1                = DUC_LINEUP_param.HB_filt6.base_addr1 + 128;


%% Simulation Parameters
DUC_LINEUP_param.SampleTime                         = 1;                           % One unit in Simulink simulation is one clock cycle 
DUC_LINEUP_param.endTime                            = 20000;                       % How many simulation clock cycles
DUC_LINEUP_param.ContiguousValidFrames              = 1;                           % Create a sequence of valid and invali frames of stimulus data in the Channelizer block
DUC_LINEUP_param.ContiguousInvalidFrames            = 1; 


%********************************** SINGLE TONE TEST *********************************************

carr1_file_data_vec                                 = load('power_meter_tc01_singletone20_30p72_0.mat');
carr1_file_data                                     = carr1_file_data_vec.Hepta_Test_Vector_Data;

real_data1                                          = carr1_file_data(1:2:end);
imag_data1                                          = carr1_file_data(2:2:end);

fvtool(complex(real_data1,imag_data1),'fs',30.72e6);
zero_data                                           = zeros(1,length(real_data1));

DUC_LINEUP_param.inputdata_A1xC1(1,:)              = zero_data;
DUC_LINEUP_param.inputdata_A1xC1(1,:)             = imag_data1*2^16+real_data1;




%% Derived Parameters 
DUC_LINEUP_param.Period_A1xC1                       = ceil(DUC_LINEUP_param.ClockRate / DUC_LINEUP_param.SampleRate_A1xC1);           % Clock cycles between consecutive data samples for a particular channel
 REG.FirTap4                                             = 2048+1024;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration 0 Configurations
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 Iter0_Param.BaseAddr                                    = DUC_LINEUP_param.HB_filt7.base_addr1 + 256; % processor interface start address


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration 1 Configurations
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Iter1_Param.BaseAddr                                    = Iter0_Param.BaseAddr + REG.FirTap4 + 128 ; % processor interface start address


% %%%%%%%%%%%%%%%%%% DPD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


StartAddress1                                           = Iter1_Param.BaseAddr + REG.FirTap4 + 128;
StartAddress2                                           = StartAddress1+1024 ;




%%%%%%%%%%%%%%%%%% GAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ant1_carr1_gain_addr                                    = StartAddress2 + 1024;
ant1_carr2_gain_addr                                    = ant1_carr1_gain_addr + 1;
ant1_carr3_gain_addr                                    = ant1_carr2_gain_addr + 1;
ant1_carr4_gain_addr                                    = ant1_carr3_gain_addr + 1;

ant2_carr1_gain_addr                                    = ant1_carr4_gain_addr + 1;
ant2_carr2_gain_addr                                    = ant2_carr1_gain_addr + 1;
ant2_carr3_gain_addr                                    = ant2_carr2_gain_addr + 1;
ant2_carr4_gain_addr                                    = ant2_carr3_gain_addr + 1;

ant1_summer_gain_addr                                   = ant2_carr4_gain_addr + 1;
ant2_summer_gain_addr                                   = ant1_summer_gain_addr + 1;

dpd1_gain_addr                                          = ant2_summer_gain_addr +1;
dpd2_gain_addr                                          = dpd1_gain_addr + 1;




power_meter_param.carr1_pd_address                      = dpd2_gain_addr+16;
power_meter_param.carr2_pd_address                      = power_meter_param.carr1_pd_address+1;
power_meter_param.carr3_pd_address                      = power_meter_param.carr2_pd_address+1;
power_meter_param.carr4_pd_address                      = power_meter_param.carr3_pd_address+1;
power_meter_param.carr5_pd_address                      = power_meter_param.carr4_pd_address+1;
power_meter_param.carr6_pd_address                      = power_meter_param.carr5_pd_address+1;
power_meter_param.carr7_pd_address                      = power_meter_param.carr6_pd_address+1;
power_meter_param.carr8_pd_address                      = power_meter_param.carr7_pd_address+1;


power_meter_param.carr1_acc1_reg_addr                   = power_meter_param.carr8_pd_address+1; 
power_meter_param.carr1_acc2_reg_addr                   = power_meter_param.carr1_acc1_reg_addr +1;
power_meter_param.carr2_acc1_reg_addr                   = power_meter_param.carr1_acc2_reg_addr +1;
power_meter_param.carr2_acc2_reg_addr                   = power_meter_param.carr2_acc1_reg_addr +1;
power_meter_param.carr3_acc1_reg_addr                   = power_meter_param.carr2_acc2_reg_addr +1;
power_meter_param.carr3_acc2_reg_addr                   = power_meter_param.carr3_acc1_reg_addr +1;
power_meter_param.carr4_acc1_reg_addr                   = power_meter_param.carr3_acc2_reg_addr +1;
power_meter_param.carr4_acc2_reg_addr                   = power_meter_param.carr4_acc1_reg_addr +1;
power_meter_param.carr5_acc1_reg_addr                   = power_meter_param.carr4_acc2_reg_addr +1;
power_meter_param.carr5_acc2_reg_addr                   = power_meter_param.carr5_acc1_reg_addr +1;
power_meter_param.carr6_acc1_reg_addr                   = power_meter_param.carr5_acc2_reg_addr +1;
power_meter_param.carr6_acc2_reg_addr                   = power_meter_param.carr6_acc1_reg_addr +1;
power_meter_param.carr7_acc1_reg_addr                   = power_meter_param.carr6_acc2_reg_addr +1;
power_meter_param.carr7_acc2_reg_addr                   = power_meter_param.carr7_acc1_reg_addr +1;
power_meter_param.carr8_acc1_reg_addr                   = power_meter_param.carr7_acc2_reg_addr +1;
power_meter_param.carr8_acc2_reg_addr                   = power_meter_param.carr8_acc1_reg_addr +1;


power_meter_param.summer_ant1_pd_address                = power_meter_param.carr8_acc2_reg_addr+1;
power_meter_param.summer_ant2_pd_address                = power_meter_param.summer_ant1_pd_address+1;

power_meter_param.summer_ant1_acc1_reg_addr             = power_meter_param.summer_ant2_pd_address+1;
power_meter_param.summer_ant1_acc2_reg_addr             = power_meter_param.summer_ant1_acc1_reg_addr +1;
power_meter_param.summer_ant2_acc1_reg_addr             = power_meter_param.summer_ant1_acc2_reg_addr +1;
power_meter_param.summer_ant2_acc2_reg_addr             = power_meter_param.summer_ant2_acc1_reg_addr +1;

power_meter_param.dpd1_out_acc1_reg_addr                = power_meter_param.summer_ant2_acc2_reg_addr + 1;
power_meter_param.dpd1_out_acc2_reg_addr                = power_meter_param.dpd1_out_acc1_reg_addr + 1;
power_meter_param.dpd2_out_acc1_reg_addr                = power_meter_param.dpd1_out_acc2_reg_addr + 1;
power_meter_param.dpd2_out_acc2_reg_addr                = power_meter_param.dpd2_out_acc1_reg_addr + 1;

power_meter_param.dpd1_out_pd_address                   = power_meter_param.dpd2_out_acc2_reg_addr + 1;
power_meter_param.dpd2_out_pd_address                   = power_meter_param.dpd1_out_pd_address +1;

power_meter_param.dpd1_in_acc1_reg_addr                 = power_meter_param.dpd2_out_pd_address +1;
power_meter_param.dpd1_in_acc2_reg_addr                 = power_meter_param.dpd1_in_acc1_reg_addr +1;

power_meter_param.dpd1_in_pd_address                    = power_meter_param.dpd1_in_acc2_reg_addr  +1;
power_meter_param.dpd2_in_pd_address                    = power_meter_param.dpd1_in_pd_address +1;

power_meter_param.dpd2_in_acc1_reg_addr                 = power_meter_param.dpd2_in_pd_address +1;
power_meter_param.dpd2_in_acc2_reg_addr                 = power_meter_param.dpd2_in_acc1_reg_addr +1;







