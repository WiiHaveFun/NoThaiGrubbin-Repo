function shadeRegion(xCells, yCells, types, xrange)
% shadeRegion(xCells, yCells, types, xrange)
%
% Inputs:
%   xCells : cell array of x-data vectors
%   yCells : cell array of y-data vectors
%   types  : cell array of 'upper' or 'lower' for each curve
%   xrange : [xmin xmax npoints] to define interpolation grid
%
% Example:
%   x1 = 0:0.1:5; y1 = 0.5*x1 + 1;
%   x2 = 2:0.1:10; y2 = 0.2*(x2-2).^2 + 2;
%   x3 = 0:0.1:10; y3 = 6 - 0.3*x3;
%   x4 = 1:0.1:9;  y4 = 5*exp(-0.1*(x4-5).^2) + 3;
%
%   xCells = {x1,x2,x3,x4};
%   yCells = {y1,y2,y3,y4};
%   types  = {'lower','lower','upper','upper'};
%   shadeRegion(xCells, yCells, types, [0 10 500]);

% --- build grid
xg = linspace(xrange(1), xrange(2), xrange(3));

% --- initialize arrays
lowerBounds = nan(length(xCells), length(xg));
upperBounds = nan(length(xCells), length(xg));

% --- interpolate each curve
for i = 1:length(xCells)
    yi = interp1(xCells{i}, yCells{i}, xg, 'linear', 'extrap');
    if strcmpi(types{i}, 'lower')
        lowerBounds(i,:) = yi;
    elseif strcmpi(types{i}, 'upper')
        upperBounds(i,:) = yi;
    else
        error('types{%d} must be ''upper'' or ''lower''.', i);
    end
end

% --- combine bounds
lowerBound = max(lowerBounds, [], 1, 'omitnan');
upperBound = min(upperBounds, [], 1, 'omitnan');

% --- clamp missing regions to axis edges
yl = ylim; % current axis limits
lowerBound(isnan(lowerBound)) = yl(1);
upperBound(isnan(upperBound)) = yl(2);

% --- enforce feasible region only
mask = lowerBound <= upperBound;
lowerBound(~mask) = NaN;
upperBound(~mask) = NaN;

% --- break into continuous valid segments
inRegion = ~isnan(lowerBound) & ~isnan(upperBound);
d = diff([false, inRegion, false]);
starts = find(d == 1);
ends   = find(d == -1) - 1;

hold on;
for k = 1:numel(starts)
    idx = starts(k):ends(k);
    fill([xg(idx) fliplr(xg(idx))], ...
         [lowerBound(idx) fliplr(upperBound(idx))], ...
         [0, 1.0, 0], 'FaceAlpha', 0.05, 'EdgeColor', 'none');
end
end
