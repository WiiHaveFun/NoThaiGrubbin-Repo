function label_line(h, x, dn, txt, varargin)
%LABELLINE Add a text label to a line object at a given position.
%   labelLine(h, x, dn, txt) places the text string txt on the line object h
%   at the location corresponding to the given x-coordinate.
%
%   labelLine(h, [x y], dn, txt) allows explicit (x,y) specification.
%
%   Special handling:
%       - If the local segment is vertical (neighboring XData are equal):
%           * If user passes [x y], y is used directly.
%           * Otherwise, the label is placed at the top of the axis
%             with HorizontalAlignment = 'right'.
%       - If interp1 fails (non-monotonic XData), falls back to nearest point.
%
%   The label is rotated to match the slope of the line and offset by dn
%   units normal to the line (in screen space).
%
%   Additional name-value pairs are passed to the TEXT function.

    % Get line data
    xd = get(h, 'XData');
    yd = get(h, 'YData');
    ax = ancestor(h,'axes');

    % Handle optional y input
    if numel(x) == 2
        xv = x(1);
        yv = x(2);
        ySpecified = true;
    else
        xv = x;
        yv = [];
        ySpecified = false;
    end

    % --- Locate nearest index to requested x ---
    [~, idx] = min(abs(xd - xv));
    if idx == 1
        idx = 2;
    elseif idx == numel(xd)
        idx = numel(xd)-1;
    end

    % Check if local segment is vertical
    local_dx = xd(idx+1) - xd(idx-1);
    local_dy = yd(idx+1) - yd(idx-1);

    if abs(local_dx) < eps   % vertical local segment
        if isempty(yv)
            ylim_ = get(ax,'YLim');
            yv = ylim_(2); % top of axis
        end
        xv = xd(idx);   % vertical line's x
        tx = 0; ty = 1; % vertical tangent
        useRightAlign = ~ySpecified;

    else
        % ----- Robust interpolation -----
        if isempty(yv)
            try
                yv = interp1(xd, yd, xv, 'linear');
            catch
                % fallback: nearest neighbor
                [~, idx2] = min(abs(xd - xv));
                yv = yd(idx2);
            end
        end

        dx = local_dx;
        dy = local_dy;
        useRightAlign = false;
    end

    % Axis scaling correction
    units = get(ax,'Units'); set(ax,'Units','pixels');
    axpos = get(ax,'Position'); % in pixels
    set(ax,'Units',units);

    % Data aspect ratios
    xlim = get(ax,'XLim');
    ylim_ = get(ax,'YLim');
    dx_data = diff(xlim);
    dy_data = diff(ylim_);

    % Scaling factors (data → pixels)
    sx = axpos(3) / dx_data;
    sy = axpos(4) / dy_data;

    % Tangent vector in screen coords
    if ~exist('tx','var')
        tx = dx * sx;
        ty = dy * sy;
    end

    % Handle degenerate tangent
    if hypot(tx,ty) < eps
        tx = 1; ty = 0; % default horizontal
    end

    % Normal vector (perpendicular in screen space)
    nx = -ty;
    ny = tx;

    % Normalize and scale by dn
    nlen = hypot(nx, ny);
    if nlen < eps
        nx = 0; ny = 0;
    else
        nx = nx / nlen * dn;
        ny = ny / nlen * dn;
    end

    % Convert offset back into data units
    x_off = nx / sx;
    y_off = ny / sy;

    % Corrected angle in degrees
    ang = atan2(ty, tx) * 180/pi;

    % Alignment choice
    if useRightAlign
        hAlign = 'right';
    else
        hAlign = 'center';
    end

    % Place text
    text(xv + x_off, yv + y_off, txt, 'Rotation', ang, ...
        'HorizontalAlignment', hAlign, ...
        'VerticalAlignment','middle', ...
        'Color', get(h,'Color'), varargin{:});
end
