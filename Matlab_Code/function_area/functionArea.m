%% Copyright 2014 MERCIER David
function Ac = functionArea(hc, coeffArea, varargin)
%% Function used to calculate the contact area from
% Oliver et al. (1992) - http://dx.doi.org/10.1557/JMR.1992.1564

% Ac: Contact area calculation in nm2

if nargin < 2
    coeffArea = [24.56 0 0 0 0 0 0 0 0]; % Coefficients of the function area
end

if nargin < 1
    hc = 100; % Contact indentation depth in nm
end

Ac = coeffArea(1).*hc.^2 + ...
    coeffArea(2).*hc.^1 + ...
    coeffArea(3).*hc.^(1/2) + ...
    coeffArea(4).*hc.^(1/4) + ...
    coeffArea(5).*hc.^(1/8) + ...
    coeffArea(6).*hc.^(1/16) + ...
    coeffArea(7).*hc.^(1/32) + ...
    coeffArea(8).*hc.^(1/64) + ...
    coeffArea(9).*hc.^(1/128);

end