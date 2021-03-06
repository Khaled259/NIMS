%% Copyright 2014 MERCIER David
function model_multilayer_elastic(val2)
%% Function used to calculate Young's modulus in multilayer system with the model of Mercier et al. (2010)
gui = guidata(gcf);

%% Setting variables & parameters
gui.data.Es_red = reduced_YM(gui.data.Es, gui.data.nus); % Reduced Young's modulus of the substrate (in GPa)
gui.data.E0_red = reduced_YM(gui.data.E0, gui.data.nuf0); % Reduced Young's modulus of the film 0 (in GPa)
gui.data.E1_red = reduced_YM(gui.data.E1, gui.data.nuf1); % Reduced Young's modulus of the film 1 (in GPa)

gui.results.ac2 = gui.results.ac;
gui.axis.legend2 = 'Results with the multilayer model';

% Thickness correction
if get(gui.handles.cb_corr_thickness_GUI, 'Value') == 1
    gui.results.t2_corr = gui.data.t2 - ...
        (gui.variables.thickness_correctionFactor .* gui.results.hc);
else
    gui.results.t2_corr = gui.data.t2;
end

if gui.variables.num_thinfilm == 4
    gui.results.ac1 = gui.results.ac2 + ((2.*gui.data.t2)./pi);
    gui.results.t1_corr = gui.data.t1;
    
elseif gui.variables.num_thinfilm == 3
    gui.results.ac1 = gui.results.ac;
    
    if get(gui.handles.cb_corr_thickness_GUI, 'Value') == 1
        gui.results.t1_corr = gui.data.t1 - ...
            (gui.variables.thickness_correctionFactor .* gui.results.hc);
    else
        gui.results.t1_corr = gui.data.t1;
    end
end

gui.results.ac0     = gui.results.ac1 + ((2.*gui.data.t1)./pi);
gui.results.t0_corr = gui.data.t0;
guidata(gcf, gui);

%% Optimization of Young's modulus of the thin film
if val2 ~= 1
    if gui.variables.y_axis > 3
        
        OPTIONS = algoMinimization;
        
        % 2 Films + Substrat
        if gui.variables.num_thinfilm == 3 && val2 == 2 % Mercier et al. (2010)
            model_mercier_2layers(OPTIONS);
            
            %3 Films + Substrat
        elseif gui.variables.num_thinfilm == 4 && val2 == 2 % Mercier et al. (2010)
            model_mercier_3layers(OPTIONS);
        end
        
    end
    gui = guidata(gcf); guidata(gcf, gui);
    gui.results.Em = non_reduced_YM(gui.results.Em_red, gui.data.nuf);
    gui.results.Ef = non_reduced_YM(gui.results.Ef_red, gui.data.nuf);
    guidata(gcf, gui);
    
elseif val2 == 1 % No Bilayer Model
    emptyVariables;
    gui = guidata(gcf); guidata(gcf, gui);
    
end

set(gui.MainWindows, 'CurrentAxes', gui.handles.AxisPlot_GUI);
guidata(gcf, gui);

end