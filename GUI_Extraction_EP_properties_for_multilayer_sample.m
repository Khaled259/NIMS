%% Copyright 2014 MERCIER David
function gui_handle = GUI_Extraction_EP_properties_for_multilayer_sample
%% Function to run the Matlab GUI for the calculations of elastic-plastic properties
% of a multilayer system from indentation experiments with a conical indenter

%% Initialization
clear all; close all; clear classes;
delete(findall(0,'Type','figure'));
format compact;
commandwindow; clc; clearvars;

%% Paths Management
path_management_GUI; %Definition of the Matlab search paths
if ismac || isunix
    addpath(genpath('path\to\codes'));
else
    addpath(genpath('path/to/codes'));
end

[startdir, f, ext] = fileparts(mfilename('fullpath'));
cd(startdir);

%% Import data from YAML config file
configYAML = sprintf('GUI_config.yaml');

if ~exist(configYAML, 'file')
    errordlg('YAML File not found !', 'File Error');
    gui.config = struct();
else
    try
        gui.config = ReadYaml(configYAML);
        flag_YAML = 1;
    catch
        gui.config = [];
        flag_YAML = 0;
        if isfield(gui.config, 'gui.config.Indenter_IDs') == 0
            gui.config.Indenter_IDs = {'No Indenter defined'};
        end
        
        if isfield(gui.config, 'gui.config.Indenter_ID') == 0
            gui.config.Indenter_ID = 'No Indenter defined';
        end
        
        if isfield(gui.config, 'gui.config.Indenter_materials') == 0
            gui.config.Indenter_materials = {'No Indenter defined'};
        end
        
        if isfield(gui.config, 'gui.config.Indenter_material') == 0
            gui.config.Indenter_material = 'No Indenter defined';
        end
    end
end

if isfield(gui.config, 'data_path') == 0
    gui.config.data_path = pwd;
end

%% Set Toolbox version and help paths
gui.config.name_toolbox = 'NIMS';
gui.config.version_toolbox = '2.4';
gui.config.url_help = 'http://nims.readthedocs.org/en/latest/';

%% Main Window Coordinates Configuration
scrsize = get(0, 'ScreenSize'); % Get screen size
WX = 0.05 * scrsize(3); % X Position (bottom)
WY = 0.10 * scrsize(4); % Y Position (left)
WW = 0.90 * scrsize(3); % Width
WH = 0.80 * scrsize(4); % Height

%% Main Window Configuration
gui.handles.MainWindows = figure('Name', ...
    (strcat(gui.config.name_toolbox, ...
    ' - Version_', gui.config.version_toolbox)),...
    'NumberTitle', 'off',...
    'PaperUnits', get(0, 'defaultfigurePaperUnits'),...
    'Color', [0.9 0.9 0.9],...
    'Colormap', get(0,'defaultfigureColormap'),...
    'toolBar', 'figure',...
    'InvertHardcopy', get(0, 'defaultfigureInvertHardcopy'),...
    'PaperPosition', [0 7 50 15],...
    'Color', [0.906 0.906 0.906],...
    'Position', [WX WY WW WH]);

%% Title of the GUI
gui.handles.title_GUI_1 = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.31 0.96 0.6 0.04],...
    'String', ['Extraction of mechanical properties of thin film(s) ',...
    'on substrate by conical nanoindentation'],...
    'FontWeight', 'bold',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center',...
    'ForegroundColor', 'red');

gui.handles.title_GUI_2 = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.31 0.93 0.6 0.03],...
    'String', strcat('Version_', ...
    gui.config.version_toolbox, ' - Copyright 2014 MERCIER David'),...
    'FontWeight', 'bold',...
    'FontSize', 10,...
    'HorizontalAlignment', 'center',...
    'ForegroundColor', 'red');

%% Date / Time
gui.handles.date_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'String', datestr(datenum(clock),'mmm.dd,yyyy HH:MM'),...
    'Position', [0.92 0.975 0.075 0.02]);

%% Buttons to browse in files
gui.handles.opendata_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.018 0.95 0.06 0.04],...
    'String', 'Select file',...
    'FontSize', 10,...
    'FontWeight','bold',...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'openfile');

gui.handles.opendata_str_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.079 0.95 0.198 0.04],...
    'String', pwd,...
    'FontSize', 8,...
    'BackgroundColor', [0.9 0.9 0.9],...
    'HorizontalAlignment', 'left');

gui.handles.typedata_GUI1=uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.018 0.93 0.22 0.02],...
    'String', 'Units : Load (mN) / Displacement (nm) / Stiffness (N/m)',...
    'HorizontalAlignment', 'center');

gui.handles.typedata_GUI2=uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.018 0.91 0.22 0.02],...
    'String', ['.txt or .xls ==> 3 (or 6) columns : ', ...
    'Displacement / Load / Stiffness'],...
    'HorizontalAlignment', 'center');

gui.handles.typedata_GUI3=uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.018 0.89 0.22 0.02],...
    'String', ['.xls : XP MTS data with ''Sample''', ...
    'sheet obtained with Analyst'],...
    'HorizontalAlignment', 'center');

%% Definition of the minimum/maximum depth
gui.handles.title_mindepth_prop_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.86 0.07 0.02],...
    'String', 'Minimum depth :',...
    'HorizontalAlignment', 'left');

gui.handles.value_mindepth_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.08 0.86 0.03 0.02],...
    'String', '',...
    'Callback', 'get_and_plot');

gui.handles.unit_mindepth_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.11 0.86 0.02 0.02],...
    'String', 'nm',...
    'HorizontalAlignment', 'center');

gui.handles.title_maxdepth_prop_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.84 0.07 0.02],...
    'String', 'Maximum depth :',...
    'HorizontalAlignment', 'left');

gui.handles.value_maxdepth_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.08 0.84 0.03 0.02],...
    'String', '',...
    'Callback', 'get_and_plot');

gui.handles.unit_maxdepth_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.11 0.84 0.02 0.02],...
    'String', 'nm',...
    'HorizontalAlignment', 'center');

%% CSM corrections
gui.handles.cb_CSM_corr_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.02 0.81 0.2 0.02],...
    'String', 'CSM_correction (only valide for Berkovich indenters)',...
    'Value', 0,...
    'Callback', 'get_and_plot');

%% Choice of the indenter (only conical indenters...)
gui.handles.title_indentertype_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.77 0.1 0.02],...
    'String', 'Type of indenter',...
    'HorizontalAlignment', 'left');

gui.handles.value_indentertype_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.75 0.1 0.02],...
    'String', gui.config.Indenter_IDs,...
    'Value', 1,...
    'Callback', 'refresh_indenters_GUI');

set(gui.handles.value_indentertype_GUI, 'value', ...
    find(cell2mat(strfind(gui.config.Indenter_IDs, ...
    gui.config.Indenter_ID))));

% Berkovich tip - Creation of button group
gui.handles.bg_Berkovich_tip_GUI = uibuttongroup('Parent', gcf,...
    'Position', [0.02 0.64 0.255 0.1]);

% Vickers tip - Creation of button group
gui.handles.bg_Vickers_tip_GUI = uibuttongroup('Parent', gcf,...
    'Visible', 'off',...
    'Position', [0.02 0.64 0.255 0.1]);

% Conical tip - Creation of button group
gui.handles.bg_conical_tip_GUI = uibuttongroup('Parent', gcf,...
    'Visible', 'off',...
    'Position', [0.02 0.64 0.255 0.1]);

guidata(gcf, gui);

% Set properties of indenter
indenters_properties_GUI;

%% Encapsulation of data into the GUI
gui = guidata(gcf); guidata(gcf, gui);

%% Choice of the material indenter
gui.handles.title_indentermaterial_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.14 0.77 0.1 0.02],...
    'String', 'Material of indenter',...
    'HorizontalAlignment', 'left');

gui.handles.value_indentermaterial_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.14 0.75 0.1 0.02],...
    'String', gui.config.Indenter_materials,...
    'Value', 1,...
    'Callback', 'refresh_indenters_GUI');

set(gui.handles.value_indentermaterial_GUI, 'value', ...
    find(cell2mat(strfind(gui.config.Indenter_materials, ...
    gui.config.Indenter_material))));

guidata(gcf, gui);

%% Encapsulation of data into the GUI
gui = guidata(gcf); guidata(gcf, gui);

%% Properties of the sample
% Number of thin films
gui.handles.title_numthinfilm_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.61 0.1 0.02],...
    'String', 'Number of thin films',...
    'HorizontalAlignment', 'left');

gui.handles.value_numthinfilm_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.59 0.1 0.02],...
    'String', '0|1|2|3',...
    'Value', 4,...
    'Callback', 'refresh_indenters_GUI');

% Creation of button groups
gui.handles.bg_film2_properties_GUI = uibuttongroup(...
    'Parent', gui.handles.MainWindows, ...
    'Position', [0.02 0.5425 0.255 0.0375]);
gui.handles.bg_film1_properties_GUI = uibuttongroup(...
    'Parent', gui.handles.MainWindows, ...
    'Position', [0.02 0.5050 0.255 0.0375]);
gui.handles.bg_film0_properties_GUI = uibuttongroup(...
    'Parent', gui.handles.MainWindows, ...
    'Position', [0.02 0.4675 0.255 0.0375]);
gui.handles.bg_substrat_properties_GUI = uibuttongroup(...
    'Parent', gui.handles.MainWindows, ...
    'Position', [0.02 0.4100 0.255 0.0575]);

%% Convention
gui.handles.plot_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.14 0.59 0.08 0.03],...
    'String', 'Convention',...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'figure; imshow(''MCmodel_MERCIER2010.png'');');

%% Choice of the model for contact displacement calculation
gui.handles.title_modeldisp_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.38 0.1 0.02],...
    'String', 'Model for contact displacement calculation',...
    'HorizontalAlignment', 'left');

gui.handles.value_modeldisp_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.36 0.1 0.02],...
    'String', 'Doerner&Nix|Oliver&Pharr|Loubet',...
    'Value', 2,...
    'Callback', 'get_and_plot');

%% Correction parameters
gui.handles.title_modeldisp_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.38 0.1 0.02],...
    'String', 'Correction to apply',...
    'HorizontalAlignment', 'left');

gui.handles.popup_corr_King_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.13 0.36 0.1 0.02],...
    'String', 'beta King1987|gamma Hay1999',...
    'Value', 1,...
    'Callback', 'get_and_plot');

gui.handles.cb_corr_thickness_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.13 0.31 0.1 0.02],...
    'String', 't_eff Mencik1997',...
    'Value', 1,...
    'Visible', 'off',...
    'Callback', 'get_and_plot');

%% Choice of the model to fit load-displacement curves
gui.handles.title_loaddisp_model_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.33 0.1 0.02],...
    'String', 'Load-Disp. Model',...
    'HorizontalAlignment', 'left');

gui.handles.value_loaddisp_model_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.31 0.1 0.02],...
    'String', {'Loubet', ...
    'Hainsworth'},...
    'Value', 1,...
    'Callback', 'get_and_plot');
    
%% Choice of the bilayer/multilayer model
gui.handles.title_bilayermodel_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.33 0.1 0.02],...
    'String', 'Bilayer Model (Y''s M calc.)',...
    'Visible', 'off',...
    'HorizontalAlignment', 'left');

gui.handles.value_bilayermodel_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.31 0.1 0.02],...
    'String', {'No_Bilayer_Model', ...
    'Doerner&Nix_King',...
    'Gao_etal.',...
    'Bec_etal.',...
    'Hay_etal.',...
    'Perriot_etal.',...
    'Mencik_etal._linear',...
    'Mencik_etal._exponential',...
    'Mencik_etal._reciprocal_exp.'},...
    'Value', 1,...
    'Visible', 'off',...
    'Callback', 'get_and_plot');

gui.handles.title_multilayermodel_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.33 0.1 0.02],...
    'String', 'Multilayer Model (Y''s M calc.)',...
    'HorizontalAlignment', 'left',...
    'Visible', 'off');

gui.handles.value_multilayermodel_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.31 0.1 0.02],...
    'String', 'No_Multilayer_Model|Mercier&al.',...
    'Visible', 'off',...
    'Value', 1,...
    'Callback', 'get_and_plot');

%% Parameter to plot
gui.handles.title_param2plotinxaxis_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.26 0.1 0.02],...
    'String', 'Parameter to plot ==> x axis',...
    'HorizontalAlignment', 'left');

gui.handles.value_param2plotinxaxis_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.02 0.24 0.1 0.02],...
    'String', 'Displ.|Cont.rad./Thick.|Displ./Thick.',...
    'Value', 1,...
    'Callback', 'get_and_plot');

gui.handles.title_param2plotinyaxis_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.13 0.26 0.1 0.02],...
    'String', 'Parameter to plot ==> y axis',...
    'HorizontalAlignment', 'left');

gui.handles.value_param2plotinyaxis_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [0.13 0.24 0.1 0.02],...
    'String', {'Load', ...
    'Stiffness', ...
    'Load oved Stiffness squared', ...
    'Red. Young''s modulus(film+sub)', ...
    'Red. Young''s modulus(film)', ...
    'Hardness'},...
    'Value', 1,...
    'Callback', 'get_and_plot');

%% Options of the plot
gui.handles.cb_log_plot_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.02 0.19 0.05 0.03],...
    'String', 'Log',...
    'Value', 0,...
    'Callback', 'get_and_plot');

gui.handles.cb_grid_plot_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.07 0.19 0.05 0.03],...
    'String', 'Grid',...
    'Value', 1,...
    'Callback', 'get_and_plot');

gui.handles.cb_residual_plot_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.13 0.19 0.1 0.03],...
    'String', 'Residuals',...
    'Visible', 'off',...
    'Value', 0,...
    'Callback', 'get_and_plot');

%% Plot configuration
gui.handles.AxisPlot_GUI = axes('Parent', gcf,...
    'Position', [0.33 0.1 0.65 0.75]);

set(gui.handles.MainWindows,'CurrentAxes', gui.handles.AxisPlot_GUI);

%% Get values from plot
gui.handles.cb_get_values_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.02 0.15 0.1 0.03],...
    'String', 'Get x and y values',...
    'Callback', 'plot_get_values');

gui.handles.title_x_values_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.13 0.03 0.02],...
    'String', 'X value :',...
    'HorizontalAlignment', 'left');

gui.handles.value_x_values_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.05 0.13 0.03 0.02],...
    'String', '');

gui.handles.title_y_values_prop_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.02 0.11 0.03 0.02],...
    'String', 'Y value :',...
    'HorizontalAlignment', 'left');

gui.handles.value_y_values_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.05 0.11 0.03 0.02],...
    'String', '');

%% Others buttons
% Python for FEM (Abaqus)
gui.handles.python4fem = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.13 0.12 0.1 0.05],...
    'String', 'FEM',...
    'Callback', 'python4abaqus');

% Save
gui.handles.save_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.13 0.05 0.1 0.05],...
    'String', 'SAVE',...
    'Callback', 'export_data_to_YAML_file');

% Quit
gui.handles.quit_GUI = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [0.02 0.05 0.1 0.05],...
    'String', 'QUIT',...
    'Callback', 'close(gcf);clear all');

set([gui.handles.python4fem, gui.handles.save_GUI, gui.handles.quit_GUI],...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745]);

%% Help menu
customized_menu(gcf);

%% Set flags
gui.flag.flag = 0;
gui.flag.flag_data = 0;
guidata(gcf, gui);

if flag_YAML
    %% Initialization of indenter properties
    refresh_indenters_GUI(0);
    
    %% Set properties of thin films
    thin_films_properties_GUI;
    
    %% Encapsulation of data into the GUI
    gui = guidata(gcf); guidata(gcf, gui);
    
    gui_handle = ishandle(gcf);
else
    fprintf(['<a href="https://code.google.com/p/yamlmatlab/">', ...
        'Please download YAML Matlab code first...!</a>']);
    dos('start https://code.google.com/p/yamlmatlab/ ');
    errordlg(['Please download YAML Matlab code first... --> ', ...
        'https://code.google.com/p/yamlmatlab/'], 'Error');
end

end

function path_management_GUI(varargin)
%% Set Matlab search path
% http://www.mathworks.de/de/help/matlab/ref/addpath.html
commandwindow;
% http://stackoverflow.com/questions/2720140/find-location-of-current-m-file-in-matlab
S = dbstack('-completenames');
[folder, name, ext] = fileparts(S(1).file);
display (folder);

if nargin > 0 && ischar(varargin{1})
    answer = varargin{1};
else
    answer = input(['Add the above folder with subfolders to the MATLAB', ...
        'search path ?\n ([y](default)/n/rm(remove))'],'s');
end

path_to_add = genpath(folder);
% TODO: remove everything under .git/...
% this will be much easier with strsplit, available from matlab2013a (8.1)
path_cell = regexp(path_to_add, pathsep, 'split');
%try
path_cell_genpath = path_cell;
path_cell = cellstr_filter(path_cell, {'.git'});
filtered_entries = numel(path_cell_genpath) - numel(path_cell)

n_dirs = numel(path_cell);

path_to_add = cell2path(path_cell);

if strcmpi(answer, 'y') || isempty(answer)
    display(sprintf('Adding %i entries to matlab search path', n_dirs));
    addpath(path_to_add);
    %rmpath(path_to_ignore)
    %savepath;
elseif strcmpi(answer, 'rm')
    display(sprintf('Removing %i entries from matlab search path', n_dirs));
    rmpath(path_to_add);
else
    display 'doing nothing';
end

%% Optionally display the matlab search path after modifications with the 'path' command
%path
end

function path_cell_filtered = cellstr_filter(path_cell, extension2filter)

for ii = 1:length(path_cell)
    if strcmp(path_cell{ii}, extension2filter) == 1;
        path_cell{ii} = {''};
    end
end
path_cell_filtered = path_cell;
end

function path_list = cell2path(path_cell)

path_strcat = '';

for ii = 1:length(path_cell)
    path_strcat = strcat(path_strcat, ';', path_cell{ii});
end
path_list = path_strcat;
end