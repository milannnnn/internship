function PPC(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.
%
%   It should be noted that the MATLAB S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%
%   Copyright 2003-2010 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 9;
block.NumOutputPorts = 9;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(1).SamplingMode = 'Sample';

block.InputPort(2).Dimensions        = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.InputPort(2).SamplingMode = 'Sample';

block.InputPort(3).Dimensions        = 1;
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).DirectFeedthrough = true;
block.InputPort(3).SamplingMode = 'Sample';

block.InputPort(4).Dimensions        = 1;
block.InputPort(4).DatatypeID  = 0;  % double
block.InputPort(4).Complexity  = 'Real';
block.InputPort(4).DirectFeedthrough = true;
block.InputPort(4).SamplingMode = 'Sample';

block.InputPort(5).Dimensions        = 1;
block.InputPort(5).DatatypeID  = 0;  % double
block.InputPort(5).Complexity  = 'Real';
block.InputPort(5).DirectFeedthrough = true;
block.InputPort(5).SamplingMode = 'Sample';

block.InputPort(6).Dimensions        = 1;
block.InputPort(6).DatatypeID  = 0;  % double
block.InputPort(6).Complexity  = 'Real';
block.InputPort(6).DirectFeedthrough = true;
block.InputPort(6).SamplingMode = 'Sample';

block.InputPort(7).Dimensions        = 1;
block.InputPort(7).DatatypeID  = 0;  % double
block.InputPort(7).Complexity  = 'Real';
block.InputPort(7).DirectFeedthrough = true;
block.InputPort(7).SamplingMode = 'Sample';

block.InputPort(8).Dimensions        = 1;
block.InputPort(8).DatatypeID  = 0;  % double
block.InputPort(8).Complexity  = 'Real';
block.InputPort(8).DirectFeedthrough = true;
block.InputPort(8).SamplingMode = 'Sample';

block.InputPort(9).Dimensions        = 1;
block.InputPort(9).DatatypeID  = 0;  % double
block.InputPort(9).Complexity  = 'Real';
block.InputPort(9).DirectFeedthrough = true;
block.InputPort(9).SamplingMode = 'Sample';

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(2).Dimensions       = 1;
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

block.OutputPort(3).Dimensions       = 1;
block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Real';
block.OutputPort(3).SamplingMode = 'Sample';

block.OutputPort(4).Dimensions       = 1;
block.OutputPort(4).DatatypeID  = 0; % double
block.OutputPort(4).Complexity  = 'Real';
block.OutputPort(4).SamplingMode = 'Sample';

block.OutputPort(5).Dimensions       = 1;
block.OutputPort(5).DatatypeID  = 0; % double
block.OutputPort(5).Complexity  = 'Real';
block.OutputPort(5).SamplingMode = 'Sample';

block.OutputPort(6).Dimensions       = 1;
block.OutputPort(6).DatatypeID  = 0; % double
block.OutputPort(6).Complexity  = 'Real';
block.OutputPort(6).SamplingMode = 'Sample';

block.OutputPort(7).Dimensions       = 1;
block.OutputPort(7).DatatypeID  = 0; % double
block.OutputPort(7).Complexity  = 'Real';
block.OutputPort(7).SamplingMode = 'Sample';

block.OutputPort(8).Dimensions       = 1;
block.OutputPort(8).DatatypeID  = 0; % double
block.OutputPort(8).Complexity  = 'Real';
block.OutputPort(8).SamplingMode = 'Sample';

block.OutputPort(9).Dimensions       = 1;
block.OutputPort(9).DatatypeID  = 0; % double
block.OutputPort(9).Complexity  = 'Real';
block.OutputPort(9).SamplingMode = 'Sample';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [1 0]; 

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
%block.RegBlockMethod('Update', @Update);
%block.RegBlockMethod('Derivatives', @Derivatives);
%block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
  block.NumDworks = 39;
    
  block.Dwork(1).Name            = 'variables1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name            = 'variables2';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;
  
  block.Dwork(3).Name            = 'variables3';
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;      % double
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = true;
  
  block.Dwork(4).Name            = 'variables4';
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;      % double
  block.Dwork(4).Complexity      = 'Real'; % real
  block.Dwork(4).UsedAsDiscState = true;
  
  block.Dwork(5).Name            = 'variables5';
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0;      % double
  block.Dwork(5).Complexity      = 'Real'; % real
  block.Dwork(5).UsedAsDiscState = true;
  
  block.Dwork(6).Name            = 'variables6';
  block.Dwork(6).Dimensions      = 1;
  block.Dwork(6).DatatypeID      = 0;      % double
  block.Dwork(6).Complexity      = 'Real'; % real
  block.Dwork(6).UsedAsDiscState = true;
  
  block.Dwork(7).Name            = 'variables7';
  block.Dwork(7).Dimensions      = 1;
  block.Dwork(7).DatatypeID      = 0;      % double
  block.Dwork(7).Complexity      = 'Real'; % real
  block.Dwork(7).UsedAsDiscState = true;
  
  block.Dwork(8).Name            = 'variables8';
  block.Dwork(8).Dimensions      = 1;
  block.Dwork(8).DatatypeID      = 0;      % double
  block.Dwork(8).Complexity      = 'Real'; % real
  block.Dwork(8).UsedAsDiscState = true;
  
  block.Dwork(9).Name            = 'variables9';
  block.Dwork(9).Dimensions      = 1;
  block.Dwork(9).DatatypeID      = 0;      % double
  block.Dwork(9).Complexity      = 'Real'; % real
  block.Dwork(9).UsedAsDiscState = true;
  
  block.Dwork(10).Name            = 'variables10';
  block.Dwork(10).Dimensions      = 1;
  block.Dwork(10).DatatypeID      = 0;      % double
  block.Dwork(10).Complexity      = 'Real'; % real
  block.Dwork(10).UsedAsDiscState = true;
  
  block.Dwork(11).Name            = 'variables11';
  block.Dwork(11).Dimensions      = 1;
  block.Dwork(11).DatatypeID      = 0;      % double
  block.Dwork(11).Complexity      = 'Real'; % real
  block.Dwork(11).UsedAsDiscState = true;
  
  block.Dwork(12).Name            = 'variables12';
  block.Dwork(12).Dimensions      = 1;
  block.Dwork(12).DatatypeID      = 0;      % double
  block.Dwork(12).Complexity      = 'Real'; % real
  block.Dwork(12).UsedAsDiscState = true;
  
  block.Dwork(13).Name            = 'variables13';
  block.Dwork(13).Dimensions      = 1;
  block.Dwork(13).DatatypeID      = 0;      % double
  block.Dwork(13).Complexity      = 'Real'; % real
  block.Dwork(13).UsedAsDiscState = true;
  
  block.Dwork(14).Name            = 'variables14';
  block.Dwork(14).Dimensions      = 1;
  block.Dwork(14).DatatypeID      = 0;      % double
  block.Dwork(14).Complexity      = 'Real'; % real
  block.Dwork(14).UsedAsDiscState = true;
  
  block.Dwork(15).Name            = 'variables15';
  block.Dwork(15).Dimensions      = 1;
  block.Dwork(15).DatatypeID      = 0;      % double
  block.Dwork(15).Complexity      = 'Real'; % real
  block.Dwork(15).UsedAsDiscState = true;
  
  block.Dwork(16).Name            = 'variables16';
  block.Dwork(16).Dimensions      = 1;
  block.Dwork(16).DatatypeID      = 0;      % double
  block.Dwork(16).Complexity      = 'Real'; % real
  block.Dwork(16).UsedAsDiscState = true;
  
  block.Dwork(17).Name            = 'variables17';
  block.Dwork(17).Dimensions      = 1;
  block.Dwork(17).DatatypeID      = 0;      % double
  block.Dwork(17).Complexity      = 'Real'; % real
  block.Dwork(17).UsedAsDiscState = true;
  
  block.Dwork(18).Name            = 'variables18';
  block.Dwork(18).Dimensions      = 1;
  block.Dwork(18).DatatypeID      = 0;      % double
  block.Dwork(18).Complexity      = 'Real'; % real
  block.Dwork(18).UsedAsDiscState = true;
  
  block.Dwork(19).Name            = 'variables19';
  block.Dwork(19).Dimensions      = 1;
  block.Dwork(19).DatatypeID      = 0;      % double
  block.Dwork(19).Complexity      = 'Real'; % real
  block.Dwork(19).UsedAsDiscState = true;
  
  block.Dwork(20).Name            = 'variables20';
  block.Dwork(20).Dimensions      = 1;
  block.Dwork(20).DatatypeID      = 0;      % double
  block.Dwork(20).Complexity      = 'Real'; % real
  block.Dwork(20).UsedAsDiscState = true;
  
  block.Dwork(21).Name            = 'variables21';
  block.Dwork(21).Dimensions      = 1;
  block.Dwork(21).DatatypeID      = 0;      % double
  block.Dwork(21).Complexity      = 'Real'; % real
  block.Dwork(21).UsedAsDiscState = true;
  
  block.Dwork(22).Name            = 'variables22';
  block.Dwork(22).Dimensions      = 1;
  block.Dwork(22).DatatypeID      = 0;      % double
  block.Dwork(22).Complexity      = 'Real'; % real
  block.Dwork(22).UsedAsDiscState = true;
  
  block.Dwork(23).Name            = 'variables23';
  block.Dwork(23).Dimensions      = 1;
  block.Dwork(23).DatatypeID      = 0;      % double
  block.Dwork(23).Complexity      = 'Real'; % real
  block.Dwork(23).UsedAsDiscState = true;
  
  block.Dwork(24).Name            = 'variables24';
  block.Dwork(24).Dimensions      = 1;
  block.Dwork(24).DatatypeID      = 0;      % double
  block.Dwork(24).Complexity      = 'Real'; % real
  block.Dwork(24).UsedAsDiscState = true;
  
  block.Dwork(25).Name            = 'variables25';
  block.Dwork(25).Dimensions      = 1;
  block.Dwork(25).DatatypeID      = 0;      % double
  block.Dwork(25).Complexity      = 'Real'; % real
  block.Dwork(25).UsedAsDiscState = true;
  
  block.Dwork(26).Name            = 'variables26';
  block.Dwork(26).Dimensions      = 1;
  block.Dwork(26).DatatypeID      = 0;      % double
  block.Dwork(26).Complexity      = 'Real'; % real
  block.Dwork(26).UsedAsDiscState = true;
  
  block.Dwork(27).Name            = 'variables27';
  block.Dwork(27).Dimensions      = 1;
  block.Dwork(27).DatatypeID      = 0;      % double
  block.Dwork(27).Complexity      = 'Real'; % real
  block.Dwork(27).UsedAsDiscState = true;
  
  block.Dwork(28).Name            = 'variables28';
  block.Dwork(28).Dimensions      = 1;
  block.Dwork(28).DatatypeID      = 0;      % double
  block.Dwork(28).Complexity      = 'Real'; % real
  block.Dwork(28).UsedAsDiscState = true;
  
  block.Dwork(29).Name            = 'variables29';
  block.Dwork(29).Dimensions      = 1;
  block.Dwork(29).DatatypeID      = 0;      % double
  block.Dwork(29).Complexity      = 'Real'; % real
  block.Dwork(29).UsedAsDiscState = true;
  
  block.Dwork(30).Name            = 'variables30';
  block.Dwork(30).Dimensions      = 1;
  block.Dwork(30).DatatypeID      = 0;      % double
  block.Dwork(30).Complexity      = 'Real'; % real
  block.Dwork(30).UsedAsDiscState = true;
  
  block.Dwork(31).Name            = 'variables31';
  block.Dwork(31).Dimensions      = 1;
  block.Dwork(31).DatatypeID      = 0;      % double
  block.Dwork(31).Complexity      = 'Real'; % real
  block.Dwork(31).UsedAsDiscState = true;
  
  block.Dwork(32).Name            = 'variables32';
  block.Dwork(32).Dimensions      = 1;
  block.Dwork(32).DatatypeID      = 0;      % double
  block.Dwork(32).Complexity      = 'Real'; % real
  block.Dwork(32).UsedAsDiscState = true;  
  
  block.Dwork(33).Name            = 'variables33';
  block.Dwork(33).Dimensions      = 1;
  block.Dwork(33).DatatypeID      = 0;      % double
  block.Dwork(33).Complexity      = 'Real'; % real
  block.Dwork(33).UsedAsDiscState = true;
  
  block.Dwork(34).Name            = 'variables34';
  block.Dwork(34).Dimensions      = 1;
  block.Dwork(34).DatatypeID      = 0;      % double
  block.Dwork(34).Complexity      = 'Real'; % real
  block.Dwork(34).UsedAsDiscState = true;
  
  block.Dwork(35).Name            = 'variables35';
  block.Dwork(35).Dimensions      = 1;
  block.Dwork(35).DatatypeID      = 0;      % double
  block.Dwork(35).Complexity      = 'Real'; % real
  block.Dwork(35).UsedAsDiscState = true;
  
  block.Dwork(36).Name            = 'variables36';
  block.Dwork(36).Dimensions      = 1;
  block.Dwork(36).DatatypeID      = 0;      % double
  block.Dwork(36).Complexity      = 'Real'; % real
  block.Dwork(36).UsedAsDiscState = true;
  
  block.Dwork(37).Name            = 'variables37';
  block.Dwork(37).Dimensions      = 1;
  block.Dwork(37).DatatypeID      = 0;      % double
  block.Dwork(37).Complexity      = 'Real'; % real
  block.Dwork(37).UsedAsDiscState = true;
  
  block.Dwork(38).Name            = 'variables38';
  block.Dwork(38).Dimensions      = 1;
  block.Dwork(38).DatatypeID      = 0;      % double
  block.Dwork(38).Complexity      = 'Real'; % real
  block.Dwork(38).UsedAsDiscState = true;
  
  block.Dwork(39).Name            = 'variables39';
  block.Dwork(39).Dimensions      = 1;
  block.Dwork(39).DatatypeID      = 0;      % double
  block.Dwork(39).Complexity      = 'Real'; % real
  block.Dwork(39).UsedAsDiscState = true;

%end DoPostPropSetup


%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)
%block.Dwork(1).Data = block.DialogPrm(1).Data;
for i = 1:39
    block.Dwork(i).Data = 0;
end
    block.OutputPort(1).Data = 1;
    block.OutputPort(2).Data = 1;
    block.OutputPort(3).Data = 1;
    block.OutputPort(4).Data = 1;
    block.OutputPort(5).Data = 1;
    block.OutputPort(6).Data = 1;
    block.OutputPort(7).Data = 1;
    block.OutputPort(8).Data = 1;
    block.OutputPort(9).Data = 1;
    block.Dwork(3).Data = 1;
    block.Dwork(7).Data = 1;
    block.Dwork(11).Data = 1;
    block.Dwork(15).Data = 1;
    block.Dwork(19).Data = 1;
    block.Dwork(23).Data = 1;
    block.Dwork(27).Data = 1;
    block.Dwork(31).Data = 1;
    block.Dwork(35).Data = 1;
    
%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)

for i = 1:39
    block.Dwork(i).Data = 0;
end;
    block.OutputPort(1).Data = 1;

    block.Dwork(3).Data = 1;


%endfunction

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

  % inputs
  u1  = block.InputPort(1).Data;
  u2  = block.InputPort(2).Data;
  u3  = block.InputPort(3).Data;
  u4  = block.InputPort(4).Data;
  u5  = block.InputPort(5).Data;
  u6  = block.InputPort(6).Data;
  u7  = block.InputPort(7).Data;
  u8  = block.InputPort(8).Data;
  u9  = block.InputPort(9).Data;
  
  % def. variables
for i = 0:8
    Timer_ON(i+1) = block.Dwork(4*i+1).Data;
    Timer_OFF(i+1) = block.Dwork(4*i+2).Data;
    Working(i+1)  = block.Dwork(4*i+3).Data;
    Shutting_down(i+1) = block.Dwork(4*i+4).Data;
end
 
for i = 1 : 9
  if ((block.InputPort(i).Data >  block.OutputPort(i).Data) && (Working(i) == 0) && (Shutting_down(i) == 0)) 
      Timer_ON(i) = Timer_ON(i)+1;
      Timer_OFF(i)=0;
      
  elseif block.InputPort(i).Data == 0
      Shutting_down(i) = 1;
      Working(i) = 0;
      Timer_ON(i)=0;
  end
      
  if  Shutting_down(i)==1
      Timer_OFF(i)=  Timer_OFF(i)+1;
      Timer_ON(i)=0; 
  end
      
  if  Timer_ON(i) > 10
      block.OutputPort(i).Data = 1;
      Working(i) = 1;
      Timer_ON(i)=0;
  end
  
  if  Timer_OFF(i) > 10
      Shutting_down(i) = 0;
      Timer_OFF(i)=0;
  end
  
  if block.InputPort(i).Data==0;
      block.OutputPort(i).Data = 0;
  end
end
  
  %guardem les variables d'estat
  
for i = 0:8
    block.Dwork(4*i+1).Data = Timer_ON(i+1) ;
    block.Dwork(4*i+2).Data = Timer_OFF(i+1);
    block.Dwork(4*i+3).Data  = Working(i+1) ;
    block.Dwork(4*i+4).Data = Shutting_down(i+1) ;
end
  
  
 
  


