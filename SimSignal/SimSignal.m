function varargout = SimSignal(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State     = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @SimSignal_OpeningFcn, ...
                       'gui_OutputFcn',  @SimSignal_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end


function varargout = SimSignal_OutputFcn(hObject, eventdata, handles) 
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SimSignal (see VARARGIN)
% varargout  cell array for returning output args (see VARARGOUT)
set(hObject, 'units', 'normalized', 'position', [0.004 0.03 0.992 0.923]);           % Set the GUI size

varargout{1} = handles.output;                                                       % Get default command line output from handles structure
end


function SimSignal_OpeningFcn(hObject, eventdata, handles, varargin)
% Fixed Parameters:
handles.d_TD = 1650;                                                                 % Focal distance of the transducer [µm]

% Plot colors
handles.PlotColor_R = 0.8;
handles.PlotColor_G = 0.6;
handles.PlotColor_B = 0.9;

handles.Plot1Zoom   = 1;
handles.Plot2Zoom   = 1;
handles.NegPlot     = 1;                                                             % Plot the inverted filtered signal
handles.Plot3Range  = 300;

% Initialization values
handles.Abs_Diameter      = 18;                                                      % Absorber diameter [µm]
handles.Solid             = 1;
handles.Object            = 2;                                                       % 1) Sphere, 2) Cylinder
handles.v_abs             = 2200;                                                    % Speed of sound of absorbing material [m/s]
handles.rho_abs           = 1140;                                                    % Density of absorbing material [kg/m^3]
handles.State_Convolution = 1;                                                       % Convolution with laser pulse 0) off, 1) on
handles.LaserPulse        = 0.9;                                                     % FWHM of laser pulse [ns]
handles.BP_TD_min         = 25;    % 44
handles.BP_TD_max         = 142;   % 152
handles.BP_SW_min         = 20;
handles.BP_SW_max         = 180;
handles.Show_BP_TD        = 0;
handles.Attenuation       = 1;
handles.Depth_Tissue      = 0;
handles.Depth_Water       = handles.d_TD;

handles.FiltOrder         = 3;
handles.FiltType          = 1;

handles.Simu_Norm         = 1;
handles.Simu_Type         = 3;
handles.Simu_Min          = 1650;;
handles.Simu_Max          = 1650 + 4700;
handles.Simu_Step         = 50;

handles.output            = hObject;                                                 % Choose default command line output for SimSignal
guidata(hObject, handles);                                                           % Update handles structure

% Display Initial Values
DisplayIni(hObject, eventdata, handles);
Check_BP_Transducer_Callback(hObject, eventdata, handles);

% UIWAIT makes SimSignal wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


function handles = CalculateSignals(hObject, eventdata, handles)
% Calculate unattenuated signals and amplitude spectra
[handles.Signal, handles.Time, handles.Amplitude, ...
 handles.Frequencies, handles.Gauss, handles.RawSignal, handles.RawTime] = ...
SimulateSignal(handles.Abs_Diameter, handles.Solid, handles.Object, ...
               handles.v_abs, handles.rho_abs, handles.State_Convolution, ...
               handles.LaserPulse, 0, handles.Depth_Tissue, handles.Depth_Water);

% Calculate attenuated signals and amplitude spectra
[handles.Signal_Att, handles.Time, handles.Amplitude_Att, ...
 handles.Frequencies, handles.Gauss, handles.RawSignal, handles.RawTime] = ...
SimulateSignal(handles.Abs_Diameter, handles.Solid, handles.Object, ...
               handles.v_abs, handles.rho_abs, handles.State_Convolution, ...
               handles.LaserPulse, handles.Attenuation, handles.Depth_Tissue, ...
               handles.Depth_Water);
         
% Simulate BP filters
if handles.State_BP_Transducer         
    [handles.SignalBP1, handles.AmplitudeBP1, handles.FrequenciesBP1, ...
     handles.BW3dB, handles.BW6dB, handles.SignalBP0, handles.AmplitudeBP0, ...
     handles.FrequenciesBP0] = ...
    SimulateBandpass(handles.Signal_Att, handles.Time, handles.BP_TD_min, handles.BP_TD_max, ...
                     handles.FiltOrder, handles.FiltType, handles.State_BP_Software, ...
                     handles.BP_SW_min, handles.BP_SW_max);
            
    set(handles.Output_BW3dB, 'String', sprintf('%.4g', handles.BW3dB));
    set(handles.Output_BW6dB, 'String', sprintf('%.4g', handles.BW6dB));
end

guidata(hObject, handles);
end


function PlotSignals(hObject, eventdata, handles)
handles = CalculateSignals(hObject, eventdata, handles);
% handles = SimulateSignal(hObject, eventdata, handles);

% Collect plot data
handles.Plot1_Axis  = handles.Time;
handles.Plot1_Data  = handles.Signal_Att;

handles.Plot3_Axis  = handles.Frequencies;
handles.Plot3_Data1 = handles.Amplitude_Att;

handles.Plot4_Axis1 = handles.Time;
handles.Plot4_Axis2 = handles.RawTime;
handles.Plot4_Data1 = handles.RawSignal;
handles.Plot4_Data2 = handles.Gauss;

if handles.NegPlot == 1
    NegPlot = -1;
else
    NegPlot = 1;
end

if handles.State_BP_Transducer
    if handles.State_BP_Software
        handles.Plot2_Axis  = handles.Time;
        handles.Plot2_Data1 = NegPlot*handles.SignalBP0;
        handles.Plot2_Data2 = NegPlot*handles.SignalBP1;

        handles.Plot3_Data2 = handles.AmplitudeBP0;
        handles.Plot3_Data3 = handles.AmplitudeBP1;
    else
        handles.Plot2_Axis  = handles.Time;
        handles.Plot2_Data1 = NegPlot*handles.SignalBP1;

        handles.Plot3_Data2 = handles.AmplitudeBP1;
    end
end

% EIR_Simu = handles.SignalBP1/max(handles.SignalBP1);
% t_Simu   = handles.Time;
% save('D:\Users\dominik.soliman\Dropbox\IBMI\Matlab\HMGU Raster Scan\EIR_New.mat', 'EIR_Simu', 't_Simu');

Ap0   = max(handles.Signal);
Apf0  = max(handles.Amplitude);
ApMin = min(handles.Plot1_Data/Ap0);
ApMax = max(handles.Plot1_Data/Ap0);

% Plot the data
R = handles.PlotColor_R;
G = handles.PlotColor_G;
B = handles.PlotColor_B;

% ---------------- Plot 1 ----------------
plot(handles.Plot1, handles.Plot1_Axis, handles.Plot1_Data/Ap0, ...
     'LineWidth', 2.3, 'Color', [0, 0, B]);

xlabel(handles.Plot1, 't (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
       'FontSize', 15);
   
if handles.Plot1Zoom
    set(handles.Plot1, 'XLim', [-0.5e-7 0.5e-7]);
    set(handles.Plot1, 'XTick', [-0.5e-7 -0.25e-7 0 0.25e-7 0.5e-7]);
    set(handles.Plot1, 'XTickLabel', [-50 -25 0 25 50]);
else
    set(handles.Plot1, 'XLim', [-1e-7 1e-7]);
    set(handles.Plot1, 'XTick', [-1e-7 -0.5e-7 0 0.5e-7 1e-7]);
    set(handles.Plot1, 'XTickLabel', [-100 -50 0 50 100]);
end

set(handles.Plot1, 'YLim', [ApMin*1.1 ApMax*1.1]);

% ---------------- Plot 2 ----------------
if handles.State_BP_Transducer
    if handles.State_BP_Software
        if handles.Show_BP_TD
            set(handles.Plot2, 'NextPlot', 'replace');
            plot(handles.Plot2, handles.Plot2_Axis, handles.Plot2_Data1/Ap0, ...
                 'LineWidth', 2.3, 'Color', [0, G, 0]);
            set(handles.Plot2, 'NextPlot', 'add');
            hold all;
            plot(handles.Plot2, handles.Plot2_Axis, handles.Plot2_Data2/Ap0, ...
                 'LineWidth', 2.3, 'Color', [R, 0, 0]);
            hold off;
            set(handles.Plot2, 'NextPlot', 'replace');
            ApMin = min(handles.Plot2_Data1/Ap0);
            ApMax = max(handles.Plot2_Data1/Ap0);
        else
            plot(handles.Plot2, handles.Plot2_Axis, handles.Plot2_Data2/Ap0, ...
                 'LineWidth', 2.3, 'Color', [0, G, 0]);
            ApMin = min(handles.Plot2_Data2/Ap0);
            ApMax = max(handles.Plot2_Data2/Ap0);
        end
    else    
        plot(handles.Plot2, handles.Plot2_Axis, handles.Plot2_Data1/Ap0, ...
             'LineWidth', 2.3, 'Color', [0, G, 0]);
        ApMin = min(handles.Plot2_Data1/Ap0);
        ApMax = max(handles.Plot2_Data1/Ap0);
    end
    
    xlabel(handles.Plot2, 't (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
           'FontSize', 15);
    
    if handles.Plot2Zoom
        set(handles.Plot2, 'XLim', [-0.5e-7 0.5e-7]);
        set(handles.Plot2, 'XTick', [-0.5e-7 -0.25e-7 0 0.25e-7 0.5e-7]);
        set(handles.Plot2, 'XTickLabel', [-50 -25 0 25 50]);
    else
        set(handles.Plot2, 'XLim', [-1e-7 1e-7]);
        set(handles.Plot2, 'XTick', [-1e-7 -0.5e-7 0 0.5e-7 1e-7]);
        set(handles.Plot2, 'XTickLabel', [-100 -50 0 50 100]);
    end
    
    set(handles.Plot2, 'YLim', [ApMin*1.1 ApMax*1.1]);
end

% ---------------- Plot 3 ----------------
plot(handles.Plot3, handles.Plot3_Axis, handles.Plot3_Data1/Apf0, ...
     'LineWidth', 2.3, 'Color', [0, 0, B]);
 
Apf = max(handles.Plot3_Data1);
 
if handles.State_BP_Transducer
    if handles.State_BP_Software
        if handles.Show_BP_TD
            hold all;
            plot(handles.Plot3, handles.Plot3_Axis, handles.Plot3_Data2/Apf0, ...
                 'LineWidth', 2.3, 'Color', [0, G, 0]);
            line([handles.BP_TD_min*1e6 handles.BP_TD_min*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
            line([handles.BP_TD_max*1e6 handles.BP_TD_max*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
            plot(handles.Plot3, handles.Plot3_Axis, handles.Plot3_Data3/Apf0, ...
                 'LineWidth', 2.3, 'Color', [R, 0, 0]);
            line([handles.BP_SW_min*1e6 handles.BP_SW_min*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', 'black');
            line([handles.BP_SW_max*1e6 handles.BP_SW_max*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', 'black');
            hold off;
        else
            hold all;
            plot(handles.Plot3, handles.Plot3_Axis, handles.Plot3_Data3/Apf0, ...
                'LineWidth', 2.3, 'Color', [0, G, 0]);
            line([handles.BP_SW_min*1e6 handles.BP_SW_min*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', 'black');
            line([handles.BP_SW_max*1e6 handles.BP_SW_max*1e6], [0 1.1], ...
                 'LineWidth', 2, 'Color', 'black');
            hold off;
        end
    else
        hold all;
        plot(handles.Plot3, handles.Plot3_Axis, handles.Plot3_Data2/Apf0, ...
             'LineWidth', 2.3, 'Color', [0, G, 0]);
        line([handles.BP_TD_min*1e6 handles.BP_TD_min*1e6], [0 1.1], 'LineWidth', ...
             2, 'Color', 'black');
        line([handles.BP_TD_max*1e6 handles.BP_TD_max*1e6], [0 1.1], 'LineWidth', ...
             2, 'Color', 'black');
        hold off;
    end
end

xlabel(handles.Plot3, 'f (Hz)', 'FontWeight', 'bold', 'units', 'normalized', ...
       'FontSize', 15);
% set(handles.Plot3, 'XLim', [0.0 300e6]);
% set(handles.Plot3, 'YLim', [0 1.1]);

set(handles.Plot3, 'XLim', [0.0 handles.Plot3Range*1e6]);
set(handles.Plot3, 'YLim', [0 1.1*Apf/Apf0]);

% ---------------- Plot 4 ----------------
R = 1;
G = 1;
B = 1;

if handles.State_Convolution
    set(handles.Plot4, 'NextPlot', 'replace');
    plot(handles.Plot4, handles.Plot4_Axis1, handles.Plot4_Data1/max(handles.Plot4_Data1), ...
         'Color', [0, 0, B]);
    hold all;
    set(handles.Plot4, 'NextPlot', 'add');
    plot(handles.Plot4, handles.Plot4_Axis2, handles.Plot4_Data2/max(handles.Plot4_Data2), ...
         'Color', [R, 0, 0]);
    hold off;
    xlabel(handles.Plot4, 't (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
           'FontSize', 10);
    set(handles.Plot4, 'XLim', [-0.5e-7 0.5e-7]);
    set(handles.Plot4, 'XTick', [-0.5e-7 -0.25e-7 0 0.25e-7 0.5e-7]);
    set(handles.Plot4, 'XTickLabel', [-50 -25 0 25 50]);
    set(handles.Plot4, 'YLim', [-1.1 1.1]);
end
end


function PlotFigure1(hObject, eventdata, handles)
handles = CalculateSignals(hObject, eventdata, handles);

% Collect plot data
handles.PlotF1_Axis  = handles.Time;
handles.PlotF1_Data  = handles.Signal_Att;

figure('position', [550 470 750 600]);
plot(handles.PlotF1_Axis, handles.PlotF1_Data/max(handles.PlotF1_Data), ...
     'LineWidth', 2.3);

xlabel(gca, 't (ns)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
ylabel(gca, 'Amplitude (norm.)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
set(gca, 'units', 'normalized', 'FontSize', 13);

set(gca, 'XLim', [-0.5e-7 0.5e-7]);
set(gca, 'XTick', [-0.5e-7 -0.25e-7 0 0.25e-7 0.5e-7]);
% set(gca, 'XTickLabel', [-50 -25 0 25 50]);
set(gca, 'XTickLabel', [0 25 50 75 100]);

set(gca, 'YLim', [-1.2 1.2]);
set(gca, 'YTick', [-1 -0.5 0 0.5 1]);
end


function PlotFigure2(hObject, eventdata, handles)
handles = CalculateSignals(hObject, eventdata, handles);

% Collect plot data
handles.PlotF2_Axis  = handles.Time;
handles.PlotF2_Data  = handles.SignalBP1;

if handles.NegPlot == 1
    NegPlot = -1;
else
    NegPlot = 1;
end

Data2 = NegPlot*handles.PlotF2_Data;

% figure('position', [550 470 750 600]);
figure;
plot(handles.PlotF2_Axis, Data2/max(Data2), ...
     'LineWidth', 2.3);

xlabel(gca, 't (ns)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
ylabel(gca, 'Amplitude (norm.)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
set(gca, 'units', 'normalized', 'FontSize', 13);

if handles.Plot2Zoom
    set(gca, 'XLim', [-0.5e-7 0.5e-7]);
    set(gca, 'XTick', [-0.5e-7 -0.25e-7 0 0.25e-7 0.5e-7]);
    set(gca, 'XTickLabel', [-50 -25 0 25 50]);
else
%     set(gca, 'XLim', [-1e-7 1e-7]);
%     set(gca, 'XTick', [-1e-7 -0.5e-7 0 0.5e-7 1e-7]);
%     set(gca, 'XTickLabel', [-100 -50 0 50 100]);
    
    set(gca, 'XLim', [-2e-7 2e-7]);
    set(gca, 'XTick', [-2e-7 -1e-7 0 1e-7 2e-7]);
    set(gca, 'XTickLabel', [-200 -100 0 100 200]);
end

set(gca, 'YLim', [min(Data2)/max(Data2)-0.2 1.2]);
set(gca, 'YTick', [-1.5 -1 -0.5 0 0.5 1 1.5]);
end


function PlotFigure3(hObject, eventdata, handles)
handles = CalculateSignals(hObject, eventdata, handles);

% Collect plot data
handles.PlotF3_Axis  = handles.Frequencies;
handles.PlotF3_Data1 = handles.Amplitude_Att;

if handles.State_BP_Transducer
    if handles.State_BP_Software
        handles.PlotF3_Data2 = handles.AmplitudeBP0;
        handles.PlotF3_Data3 = handles.AmplitudeBP1;
    else
        handles.PlotF3_Data2 = handles.AmplitudeBP1;
    end
end

% figure('position', [550 470 750 600], 'NextPlot', 'add');
figure('NextPlot', 'add')

R = handles.PlotColor_R;
G = handles.PlotColor_G;
B = handles.PlotColor_B;

Plot3_BPonly = 0;

if Plot3_BPonly
    plot(handles.PlotF3_Axis, handles.PlotF3_Data2/max(handles.PlotF3_Data2), ...
        'LineWidth', 2.3);
else
    plot(handles.PlotF3_Axis, handles.PlotF3_Data1/max(handles.PlotF3_Data1), ...
        'LineWidth', 2.3);
    
    if handles.State_BP_Transducer
        if handles.State_BP_Software
            if handles.Show_BP_TD
                hold all;
                plot(handles.PlotF3_Axis, handles.PlotF3_Data2/max(handles.PlotF3_Data1), ...
                    'LineWidth', 2.3, 'Color', [0, G, 0]);
                line([handles.BP_TD_min*1e6 handles.BP_TD_min*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
                line([handles.BP_TD_max*1e6 handles.BP_TD_max*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
                plot(handles.PlotF3_Axis, handles.PlotF3_Data3/max(handles.PlotF3_Data1), ...
                    'LineWidth', 2.3, 'Color', [R, 0, 0]);
                line([handles.BP_SW_min*1e6 handles.BP_SW_min*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', 'black');
                line([handles.BP_SW_max*1e6 handles.BP_SW_max*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', 'black');
                hold off;
            else
                hold all;
                plot(handles.PlotF3_Axis, handles.PlotF3_Data3/max(handles.PlotF3_Data1), ...
                    'LineWidth', 2.3, 'Color', [0, G, 0]);
                line([handles.BP_SW_min*1e6 handles.BP_SW_min*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', 'black');
                line([handles.BP_SW_max*1e6 handles.BP_SW_max*1e6], [0 1.1], ...
                    'LineWidth', 2, 'Color', 'black');
                hold off;
            end
        else
            hold all;
            plot(handles.PlotF3_Axis, handles.PlotF3_Data2/max(handles.PlotF3_Data1), ...
                'LineWidth', 2.3, 'Color', [0, G, 0]);
            line([handles.BP_TD_min*1e6 handles.BP_TD_min*1e6], [0 1.1], 'LineWidth', ...
                2, 'Color', 'black');
            line([handles.BP_TD_max*1e6 handles.BP_TD_max*1e6], [0 1.1], 'LineWidth', ...
                2, 'Color', 'black');
            hold off;
        end
    end
end

xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', ...
       'FontSize', 16);
ylabel(gca, 'Amplitude (norm.)', 'FontWeight', 'bold', 'units', 'normalized', ...
       'FontSize', 16);
set(gca, 'units', 'normalized', 'FontSize', 13);

% set(gca, 'XLim', [0 300e6]);
% set(gca, 'XTick', [0 100e6 200e6 300e6]);
% set(gca, 'XTickLabel', [0 100 200 300]);
% set(gca, 'YLim', [0 1.1]);

plotRange = linspace(0, handles.Plot3Range, (handles.Plot3Range+50)/50);

set(gca, 'XLim', [0 handles.Plot3Range]*1e6);
set(gca, 'XTick', plotRange*1e6);
set(gca, 'XTickLabel', plotRange);
set(gca, 'YLim', [0 1.1]);

end


function List_Object_Callback(hObject, eventdata, handles)
Obj = get(handles.List_Object, 'Value');

switch Obj
case 1
    handles.Object = 1;
    handles.Solid  = 0;
case 2
    handles.Object = 1;
    handles.Solid  = 1;
case 3
    handles.Object = 2;
    handles.Solid  = 1;
end

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Convolution_Buttons_SelectionChangeFcn(hObject, eventdata, handles)
% Executes when selected object is changed in Convolution_Buttons.
% eventdata:  structure with the following fields
% - EventName: string 'SelectionChanged' (read only)
% - OldValue: handle of the previously selected object or empty if none was selected
% - NewValue: handle of the currently selected object

handles.State_Convolution = get(handles.Convolution_On, 'Value');

if handles.State_Convolution == 0
    set(handles.Plot4, 'Visible', 'off');
    set(handles.Slider_t_Pulse, 'Visible', 'off');
    set(handles.Input_t_Pulse, 'Visible', 'off');
    set(handles.Text_t_Pulse, 'Visible', 'off');
    set(handles.Min_t_Pulse, 'Visible', 'off');
    set(handles.Max_t_Pulse, 'Visible', 'off');
    set(handles.Plot4, 'Visible', 'off');
    set(allchild(handles.Plot4), 'visible', 'off');
else
    set(handles.Plot4, 'Visible', 'on');
    set(handles.Slider_t_Pulse, 'Visible', 'on');
    set(handles.Input_t_Pulse, 'Visible', 'on');
    set(handles.Text_t_Pulse, 'Visible', 'on');
    set(handles.Min_t_Pulse, 'Visible', 'on');
    set(handles.Max_t_Pulse, 'Visible', 'on');
    set(handles.Plot4, 'Visible', 'on');
    set(allchild(handles.Plot4), 'visible', 'on');
end

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_d_Callback(hObject, eventdata, handles)
handles.Abs_Diameter = str2double(get(handles.Input_d, 'String'));
set(handles.Slider_d, 'Value', handles.Abs_Diameter);
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_d_Callback(hObject, eventdata, handles)
set(handles.Input_d, 'String', num2str(get(handles.Slider_d, 'Value')));
guidata(hObject, handles);
Input_d_Callback(hObject, eventdata, handles);
end


function Button_Agar_Callback(hObject, eventdata, handles)
handles.v_abs   = 1510;
handles.rho_abs = 1000;

set(handles.Input_v_abs, 'String', handles.v_abs);
set(handles.Input_rho_abs, 'String', handles.rho_abs);
set(handles.Slider_v_abs, 'Value', handles.v_abs);
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Button_Nylon_Callback(hObject, eventdata, handles)
handles.v_abs   = 2200;
handles.rho_abs = 1140;

set(handles.Input_v_abs, 'String', handles.v_abs);
set(handles.Input_rho_abs, 'String', handles.rho_abs);
set(handles.Slider_v_abs, 'Value', handles.v_abs);
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Button_Blood_Callback(hObject, eventdata, handles)
handles.v_abs   = 1570;
handles.rho_abs = 1060;

set(handles.Input_v_abs, 'String', handles.v_abs);
set(handles.Input_rho_abs, 'String', handles.rho_abs);
set(handles.Slider_v_abs, 'Value', handles.v_abs);
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Button_Gold_Callback(hObject, eventdata, handles)
handles.v_abs   = 1740;
handles.rho_abs = 1932;

set(handles.Input_v_abs, 'String', handles.v_abs);
set(handles.Input_rho_abs, 'String', handles.rho_abs);
set(handles.Slider_v_abs, 'Value', handles.v_abs);
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_v_abs_Callback(hObject, eventdata, handles)
handles.v_abs = str2double(get(handles.Input_v_abs, 'String'));
set(handles.Slider_v_abs, 'Value', handles.v_abs);
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_v_abs_Callback(hObject, eventdata, handles)
set(handles.Input_v_abs, 'String', num2str(get(handles.Slider_v_abs, 'Value')));
guidata(hObject, handles);
Input_v_abs_Callback(hObject, eventdata, handles);
end


function Input_rho_abs_Callback(hObject, eventdata, handles)
handles.rho_abs = str2double(get(handles.Input_rho_abs, 'String'));
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_rho_abs_Callback(hObject, eventdata, handles)
set(handles.Input_rho_abs, 'String', num2str(get(handles.Slider_rho_abs, 'Value')));
guidata(hObject, handles);
Input_rho_abs_Callback(hObject, eventdata, handles);
end


function Input_t_Pulse_Callback(hObject, eventdata, handles)
handles.LaserPulse = str2double(get(handles.Input_t_Pulse, 'String'));
set(handles.Slider_t_Pulse, 'Value', handles.LaserPulse);
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_t_Pulse_Callback(hObject, eventdata, handles)
set(handles.Input_t_Pulse, 'String', num2str(get(handles.Slider_t_Pulse, 'Value')));
guidata(hObject, handles);
Input_t_Pulse_Callback(hObject, eventdata, handles);
end


function Check_BP_Transducer_Callback(hObject, eventdata, handles)
handles.State_BP_Transducer = get(handles.Check_BP_Transducer, 'Value');

if handles.State_BP_Transducer == 0
    set(allchild(handles.Plot2), 'visible', 'off');
    
    set(handles.Check_Show_BP_Transducer, 'Visible', 'off');
    set(handles.Text_BP_Transducer_1, 'Visible', 'off');
    set(handles.Text_BP_Transducer_2, 'Visible', 'off');
    set(handles.Input_BP_Transducer_min, 'Visible', 'off');
    set(handles.Input_BP_Transducer_max, 'Visible', 'off');
    
    set(handles.Check_BP_Software, 'Visible', 'off');
    set(handles.Text_BP_Software_1, 'Visible', 'off');
    set(handles.Text_BP_Software_2, 'Visible', 'off');
    set(handles.Input_BP_Software_min, 'Visible', 'off');
    set(handles.Input_BP_Software_max, 'Visible', 'off');
    
    set(handles.Output_BW3dB, 'Visible', 'off');
    set(handles.Output_BW6dB, 'Visible', 'off');
    set(handles.Text_BW3dB, 'Visible', 'off');
    set(handles.Text_BW6dB, 'Visible', 'off');
else
    set(handles.Text_BP_Transducer_1, 'Visible', 'on');
    set(handles.Text_BP_Transducer_2, 'Visible', 'on');
    set(handles.Input_BP_Transducer_min, 'Visible', 'on');
    set(handles.Input_BP_Transducer_max, 'Visible', 'on');
    
    set(handles.Check_BP_Software, 'Visible', 'on');
    
    handles.State_BP_Software = get(handles.Check_BP_Software, 'Value');
    if handles.State_BP_Software == 0
        set(handles.Check_Show_BP_Transducer, 'Visible', 'off');
        set(handles.Text_BP_Software_1, 'Visible', 'off');
        set(handles.Text_BP_Software_2, 'Visible', 'off');
        set(handles.Input_BP_Software_min, 'Visible', 'off');
        set(handles.Input_BP_Software_max, 'Visible', 'off');
    else
        set(handles.Check_Show_BP_Transducer, 'Visible', 'on');
        set(handles.Text_BP_Software_1, 'Visible', 'on');
        set(handles.Text_BP_Software_2, 'Visible', 'on');
        set(handles.Input_BP_Software_min, 'Visible', 'on');
        set(handles.Input_BP_Software_max, 'Visible', 'on');
    end
    
    set(handles.Output_BW3dB, 'Visible', 'on');
    set(handles.Output_BW6dB, 'Visible', 'on');
    set(handles.Text_BW3dB, 'Visible', 'on');
    set(handles.Text_BW6dB, 'Visible', 'on');
end

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end

function Check_Show_BP_Transducer_Callback(hObject, eventdata, handles)
handles.Show_BP_TD = get(handles.Check_Show_BP_Transducer, 'Value');
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_BP_Transducer_min_Callback(hObject, eventdata, handles)
handles.BP_TD_min = str2double(get(handles.Input_BP_Transducer_min, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_BP_Transducer_max_Callback(hObject, eventdata, handles)
handles.BP_TD_max = str2double(get(handles.Input_BP_Transducer_max, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Check_BP_Software_Callback(hObject, eventdata, handles)
handles.State_BP_Software = get(handles.Check_BP_Software, 'Value');

if handles.State_BP_Software == 0
    set(handles.Check_Show_BP_Transducer, 'Visible', 'off');
    set(handles.Text_BP_Software_1, 'Visible', 'off');
    set(handles.Text_BP_Software_2, 'Visible', 'off');
    set(handles.Input_BP_Software_min, 'Visible', 'off');
    set(handles.Input_BP_Software_max, 'Visible', 'off');
else
    set(handles.Check_Show_BP_Transducer, 'Visible', 'on');
    set(handles.Text_BP_Software_1, 'Visible', 'on');
    set(handles.Text_BP_Software_2, 'Visible', 'on');
    set(handles.Input_BP_Software_min, 'Visible', 'on');
    set(handles.Input_BP_Software_max, 'Visible', 'on');
end

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_BP_Software_min_Callback(hObject, eventdata, handles)
handles.BP_SW_min = str2double(get(handles.Input_BP_Software_min, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_BP_Software_max_Callback(hObject, eventdata, handles)
handles.BP_SW_max = str2double(get(handles.Input_BP_Software_max, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_Order_Callback(hObject, eventdata, handles)
handles.FiltOrder = str2double(get(handles.Input_Order, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function List_Filter_Callback(hObject, eventdata, handles)
handles.FiltType = get(handles.List_Filter, 'Value');
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Toggle_Attenuation_Callback(hObject, eventdata, handles)
handles.Attenuation = get(handles.Toggle_Attenuation, 'Value');

if handles.Attenuation == 0
    set(handles.Toggle_Attenuation, 'String', 'Off');
    set(handles.Input_z_t, 'Visible', 'off');
    set(handles.Slider_z_t, 'Visible', 'off');
    set(handles.Text_z_t, 'Visible', 'off');
    set(handles.Text_z_t_i, 'Visible', 'off');
    set(handles.Text_z_t_f, 'Visible', 'off');
    set(handles.Input_z_w, 'Visible', 'off');
    set(handles.Slider_z_w, 'Visible', 'off');
    set(handles.Text_z_w, 'Visible', 'off');
    set(handles.Text_z_w_i, 'Visible', 'off');
    set(handles.Text_z_w_f, 'Visible', 'off');
    
    set(handles.Plot1_Title, 'String', 'Raw Signal (norm.)');
    set(handles.Plot3_Title, 'String', 'Amplitude Spectrum (norm.)');
else
    set(handles.Toggle_Attenuation, 'String', 'On');
    set(handles.Input_z_t, 'Visible', 'on');
    set(handles.Slider_z_t, 'Visible', 'on');
    set(handles.Text_z_t, 'Visible', 'on');
    set(handles.Text_z_t_i, 'Visible', 'on');
    set(handles.Text_z_t_f, 'Visible', 'on');
    set(handles.Input_z_w, 'Visible', 'on');
    set(handles.Slider_z_w, 'Visible', 'on');
    set(handles.Text_z_w, 'Visible', 'on');
    set(handles.Text_z_w_i, 'Visible', 'on');
    set(handles.Text_z_w_f, 'Visible', 'on');
    
    set(handles.Plot1_Title, 'String', 'Raw Signal (rel.)');
    set(handles.Plot3_Title, 'String', 'Amplitude Spectrum (rel.)');
end

guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Input_z_t_Callback(hObject, eventdata, handles)
handles.Depth_Tissue = str2double(get(handles.Input_z_t, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_z_t_Callback(hObject, eventdata, handles)
set(handles.Input_z_t, 'String', num2str(get(handles.Slider_z_t, 'Value')));
guidata(hObject, handles);
Input_z_t_Callback(hObject, eventdata, handles);
end


function Input_z_w_Callback(hObject, eventdata, handles)
handles.Depth_Water = str2double(get(handles.Input_z_w, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Slider_z_w_Callback(hObject, eventdata, handles)
set(handles.Input_z_w, 'String', num2str(get(handles.Slider_z_w, 'Value')));
guidata(hObject, handles);
Input_z_w_Callback(hObject, eventdata, handles);
end


function Button_Plot1_Callback(hObject, eventdata, handles)
PlotFigure1(hObject, eventdata, handles);
end


function Button_Plot2_Callback(hObject, eventdata, handles)
PlotFigure2(hObject, eventdata, handles);
end


function Button_Plot3_Callback(hObject, eventdata, handles)
PlotFigure3(hObject, eventdata, handles);
end


function Input_Plot3Range_Callback(hObject, eventdata, handles)
handles.Plot3Range = str2double(get(handles.Input_Plot3Range, 'String'));
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Toggle_Plot1Zoom_Callback(hObject, eventdata, handles)
handles.Plot1Zoom = get(handles.Toggle_Plot1Zoom, 'Value');
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Toggle_Plot2Zoom_Callback(hObject, eventdata, handles)
handles.Plot2Zoom = get(handles.Toggle_Plot2Zoom, 'Value');
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Toggle_NegPlot_Callback(hObject, eventdata, handles)
handles.NegPlot = get(handles.Toggle_NegPlot, 'Value');
guidata(hObject, handles);
PlotSignals(hObject, eventdata, handles);
end


function Button_RunSimu_Callback(hObject, eventdata, handles)
nSamples = 8;

if handles.Simu_Type == 1
    S = SimulateFvsD(handles.Simu_Min, handles.Simu_Max, handles.Simu_Step, 0, handles.Solid, handles.Object, handles.Plot3Range*1e6, ...
                 nSamples, handles.Simu_Norm, handles.v_abs, handles.rho_abs, handles.State_Convolution, ...
                 handles.LaserPulse, handles.State_BP_Transducer, handles.BP_TD_min, handles.BP_TD_max, ...
                 handles.Attenuation, handles.Depth_Tissue, handles.Depth_Water);

    figure('units', 'normalized', 'position', [0.24, 0.22, 0.5, 0.65]);
    imagesc([0 handles.Plot3Range], [handles.Simu_Min handles.Simu_Max], S); colormap jet; colorbar;
    
    xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 20);
    ylabel(gca, 'd_{abs} (µm)', 'FontWeight', 'bold', 'units', 'normalized', ...
        'FontSize', 20);
    set(gca, 'units', 'normalized', 'FontSize', 15);
elseif handles.Simu_Type == 2
    S = SimulateFvsPulse(handles.Simu_Min, handles.Simu_Max, handles.Simu_Step, handles.Abs_Diameter, 0, handles.Solid, ...
                     handles.Object, handles.Plot3Range*1e6, nSamples, handles.Simu_Norm, handles.v_abs, ...
                     handles.rho_abs, handles.State_BP_Transducer, handles.BP_TD_min, handles.BP_TD_max, ...
                     handles.Attenuation, handles.Depth_Tissue, handles.Depth_Water);

    figure('units', 'normalized', 'position', [0.24, 0.22, 0.5, 0.65]);
    imagesc([0 handles.Plot3Range], [handles.Simu_Min handles.Simu_Max], S); colormap jet; colorbar;
    
    xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 20);
    ylabel(gca, 't_{pulse} (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
        'FontSize', 20);
    set(gca, 'units', 'normalized', 'FontSize', 15);
elseif handles.Simu_Type == 3
    [S, BW6, fpeak] = SimulateFvsDepth(handles.Simu_Min, handles.Simu_Max, handles.Simu_Step, handles.Abs_Diameter, 0, handles.Solid, ...
                                       handles.Object, handles.Plot3Range*1e6, nSamples, handles.Simu_Norm, handles.v_abs, ...
                                       handles.rho_abs, handles.State_Convolution, handles.LaserPulse, handles.State_BP_Transducer, ...
                                       handles.BP_TD_min, handles.BP_TD_max, handles.FiltOrder, handles.FiltType);

    plotBW = 1;
                                   
    if plotBW
        z  = handles.Simu_Min:handles.Simu_Step:handles.Simu_Max;
        z  = z - handles.d_TD;
        m  = polyfit(z, fpeak(1,:), 1);
        mz = polyval(m, z);
        p  = polyfit(z, BW6(1,:), 1);
        pz = polyval(p, z);
        
        meanBW    = mean(BW6);
        meanPeak  = mean(fpeak)*1e-6;
        slope     = (pz(end)-pz(1))/(z(end)-z(1));
        
        slstring  = ['Fit BW:     ' num2str(slope*1e3) '  MHz/mm'];
        bwstring  = ['mean BW:   ' num2str(meanBW)];
        maxstring = ['mean peak:  ' num2str(meanPeak)];
        
        figure('units', 'normalized', 'position', [0.005, 0.2, 0.99, 0.6]);
    
        subplot(1, 2, 1);
        imagesc([0 handles.Plot3Range], [z(1) z(end)], S); colormap jet; colorbar;
        line([mz(1) mz(end)]*1e-6, [z(1) z(end)], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 1.5);
        xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
        ylabel(gca, 'distance to focus (µm)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
        set(gca, 'units', 'normalized', 'FontSize', 13);
        
        subplot(1, 2, 2);
        hold all;
        plot(z, pz, 'r', 'LineWidth', 2.4);
%         plot(z, BW6, '--o', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'LineWidth', 2.4);
        plot(z, BW6, 'o', 'MarkerEdgeColor', 'black', 'MarkerSize', 5);
        text(0.4, 0.25, slstring, 'units', 'normalized', 'FontSize', 15)
        text(0.4, 0.19, bwstring, 'units', 'normalized', 'FontSize', 15)
        text(0.4, 0.13, maxstring, 'units', 'normalized', 'FontSize', 15)
        hold off;
        xlabel(gca, 'distance to focus (µm)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
        ylabel(gca, 'Bandwidth (-6dB) (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 16);
        set(gca, 'units', 'normalized', 'FontSize', 13);
        set(gca, 'XLim', [z(1), z(end)]);
        set(gca, 'YLim', [0, max(max(BW6))+14]);
    else
        figure('units', 'normalized', 'position', [0.24, 0.22, 0.5, 0.65]);
        imagesc([0 handles.Plot3Range], [handles.Simu_Min handles.Simu_Max], S); colormap jet; colorbar;
        
        xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 20);
        ylabel(gca, 'depth_{µm} (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
            'FontSize', 20);
        set(gca, 'units', 'normalized', 'FontSize', 15);
    end
end
end


function List_2DSimu_Callback(hObject, eventdata, handles)
handles.Simu_Type = get(handles.List_2DSimu, 'Value');
guidata(hObject, handles);
end


function Input_Simu_Min_Callback(hObject, eventdata, handles)
handles.Simu_Min = str2double(get(handles.Input_Simu_Min, 'String'));
guidata(hObject, handles);
end


function Input_Simu_Max_Callback(hObject, eventdata, handles)
handles.Simu_Max = str2double(get(handles.Input_Simu_Max, 'String'));
guidata(hObject, handles);
end


function Input_Simu_Step_Callback(hObject, eventdata, handles)
handles.Simu_Step = str2double(get(handles.Input_Simu_Step, 'String'));
guidata(hObject, handles);
end


function Check_Simu_Norm_Callback(hObject, eventdata, handles)
handles.Simu_Norm = get(handles.Check_Simu_Norm, 'Value');
guidata(hObject, handles);
end


function DisplayIni(hObject, eventdata, handles)
set(handles.List_Object, 'Value', (handles.Solid + handles.Object));
set(handles.Input_d, 'String', handles.Abs_Diameter);
set(handles.Slider_d, 'Value', handles.Abs_Diameter);
set(handles.Input_v_abs, 'String', handles.v_abs);
set(handles.Slider_v_abs, 'Value', handles.v_abs);
set(handles.Input_rho_abs, 'String', handles.rho_abs);
set(handles.Slider_rho_abs, 'Value', handles.rho_abs);
set(handles.Input_t_Pulse, 'String', handles.LaserPulse);
set(handles.Slider_t_Pulse, 'Value', handles.LaserPulse);
set(handles.Input_BP_Transducer_min, 'String', handles.BP_TD_min);
set(handles.Input_BP_Transducer_max, 'String', handles.BP_TD_max);
set(handles.Input_BP_Software_min, 'String', handles.BP_SW_min);
set(handles.Input_BP_Software_max, 'String', handles.BP_SW_max);
set(handles.Check_BP_Transducer, 'Value', 1);
set(handles.Check_Show_BP_Transducer, 'Value', 0);
set(handles.Check_BP_Software, 'Value', 0);
set(handles.Toggle_Attenuation, 'Value', 1);
set(handles.Input_z_t, 'String', handles.Depth_Tissue);
set(handles.Slider_z_t, 'Value', handles.Depth_Tissue);
set(handles.Input_z_w, 'String', handles.Depth_Water);
set(handles.Slider_z_w, 'Value', handles.Depth_Water);
set(handles.Toggle_Plot1Zoom, 'Value', handles.Plot1Zoom);
set(handles.Toggle_Plot2Zoom, 'Value', handles.Plot2Zoom);
set(handles.Toggle_NegPlot, 'Value', handles.NegPlot);
set(handles.Input_Plot3Range, 'String', handles.Plot3Range);
set(handles.Check_Simu_Norm, 'Value', handles.Simu_Norm);
set(handles.List_2DSimu, 'Value', handles.Simu_Type);
set(handles.Input_Simu_Min, 'String', handles.Simu_Min);
set(handles.Input_Simu_Max, 'String', handles.Simu_Max);
set(handles.Input_Simu_Step, 'String', handles.Simu_Step);
set(handles.Input_Order, 'String', handles.FiltOrder);
set(handles.List_Filter, 'Value', handles.FiltType);

guidata(hObject, handles); 
end

%% ########################### Layout ###############################################

function Input_d_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor', 'white');
end
end

function Slider_d_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function Input_v_abs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor', 'white');
end
end

function Slider_v_abs_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function Input_BP_Transducer_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_BP_Transducer_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_t_Pulse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Slider_t_Pulse_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function List_Object_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Slider_rho_abs_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function Input_rho_abs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_BP_Software_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_BP_Software_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_z_t_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Slider_z_t_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function Input_z_w_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Slider_z_w_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function Input_Plot3Range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function List_2DSimu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Simu_Min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Simu_Max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Simu_Step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Order_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function List_Filter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
