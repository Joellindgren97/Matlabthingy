%b = ble("Thingy")

c = characteristic(b, "motion service", "rotation matrix")
data = read(c)

transformMatrix = eye(4);
% Populate the transform matrix with 9 rotation matrix elements
for row = 1:3
    for column = 1:3
        % Extract the 2 bytes representing the current element in the rotation matrix
        beginIndex = (row-1)*3 + (column-1);
        element = data(2*beginIndex + (1:2));
        transformMatrix(row, column) = double(typecast(uint8(element), 'int16')) / (2^14);
    end
end
% Display the transform matrix
disp(transformMatrix);

% Create a 3-D plot
ax = axes('XLim', [-1.5 1.5], 'YLim', [-1.5 1.5], 'ZLim', [-1 2]);
xlabel(ax, 'X-axis');
ylabel(ax, 'Y-axis');
zlabel(ax, 'Z-axis');
% Reverse the 2 axis directions to match the device coordinate system
set(ax, 'Zdir', 'reverse');
set(ax, 'Xdir', 'reverse');
grid on; view(3);

% Define the surface color
color = [0.3010 0.7450 0.9330];

% Create patches for all cube surfaces by specifying the four corners of each surface
top = [-1 -1 1; 1 -1 1; 1 1 1; -1 1 1];
p(1) = patch(top(:,1), top(:,2), top(:,3), color);

bottom = [-1 -1 0; 1 -1 0; 1 1 0; -1 1 0];
p(2) = patch(bottom(:,1), bottom(:,2), bottom(:,3), color);

front = [1 -1 0; 1 1 0; 1 1 1; 1 -1 1];
p(3) = patch(front(:,1), front(:,2), front(:,3), color);

back = [-1 -1 0; -1 1 0; -1 1 1; -1 -1 1];
p(4) = patch(back(:,1), back(:,2), back(:,3), color);

left = [1 -1 0; -1 -1 0; -1 -1 1; 1 -1 1];
p(5) = patch(left(:,1), left(:,2), left(:,3), color);

right = [1 1 0; -1 1 0; -1 1 1; 1 1 1];
p(6) = patch(right(:,1), right(:,2), right(:,3), color);

mark = [0.9 -0.7 -0.01; 0.7 -0.7 -0.01; 0.7 -0.9 -0.01; 0.9 -0.9 -0.01];
p(7) = patch(mark(:,1), mark(:,2), mark(:,3), 'black');

% Set the object transparency
alpha(0.5)

tfObject = hgtransform('Parent', ax);
set(p, 'Parent', tfObject);


warning('off', 'MATLAB:hg:DiceyTransformMatrix');
for loop = 1:100
    % Acquire device data
    data = read(c);
    % Prepare 4-by-4 transform matrix to plot later
    transformMatrix = eye(4);
    % Populate the transform matrix with 9 rotation matrix elements
    for row = 1:3
        for column = 1:3
            % Extract the 2 bytes representing the current element in the rotation matrix
            beginIndex = (row-1)*3 + (column-1);
            element = data(2*beginIndex + (1:2));
            transformMatrix(row, column) = double(typecast(uint8(element), 'int16')) / (2^14);
        end
    end
    
    % Update plot
    set(tfObject, 'Matrix', transformMatrix);
    pause(0.1);
end

warning('on', 'MATLAB:hg:DiceyTransformMatrix');

%clear b