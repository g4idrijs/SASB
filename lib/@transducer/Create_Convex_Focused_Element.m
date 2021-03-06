% Function Create_Convex_Focused_Element.
%  This function calculates the center positions and the corners of 
%      mathematical elements used by Field II pr. element. The function is 
%      called by the transducer class.
%    
%   Example of use:    
%   [rect center] = Create_Convex_Focused_Element(obj,Element Angle,...
%                                                 pitch,...
%                                                 kerf,...
%                                                 height,...
%                                                 elevation focus,...
%                                                 ROC,...
%                                                 ROCA,...
%                                                 nr_sub_x,...
%                                                 nr_sub_y);
%
%   Input:
%      * obj: structure passed by the transducer class
%      * Element Angle                [rad]
%      * pitch                          [m]
%      * kerf                           [m]
%      * height                         [m]
%      * elevation focus                [m]
%      * Shell radius                   [m]
%      * Radius of curvature (acoustic) [m]
%      * nr of sub elements in x dir.   
%      * nr of sub elements in y dir.
%
%   Output:
%      * rect: cornor coordinates   [x,y,z]
%      * center: center coordinate  [x,y,z]
%
%
% Martin Hemmsen (Ph.D)
% 21.03.11 (d.m.y)
% Ver. 03
% Changed the way the elements are placed in space. 
% 


function [rect, center] = Create_Convex_Focused_Element(obj,ElementAngle,pitch,kerf,height,elevation_focus,ROC,ROCA,nr_sub_x,nr_sub_y)


% calculate center of physical element
arcx       = ElementAngle;
fRad       = ROCA;
x          = fRad * cos(arcx);
z          = fRad * sin(arcx) - ROC;
center = [x 0 z];

% calculate width of physical element
width = pitch-kerf;

% calculate element scan angle
ElementScanAngle = width / ROCA;

% determine points for azimut arc
StartAngle = ElementAngle-ElementScanAngle/2;
StopAngle = ElementAngle+ElementScanAngle/2;
[x,z] = Calculate_arc_points(ROC,ROCA,StartAngle,StopAngle,nr_sub_x+1);
pos_top_arc = [x' zeros(size(x,2),1) z'];

% determine points for elevation arc
StartAngle_inner = (acos(height/2/elevation_focus));
StopAngle_inner = pi-StartAngle_inner;
[y_inner_arc,z_inner_arc] = Calculate_arc_points(elevation_focus,elevation_focus,StartAngle_inner,StopAngle_inner,nr_sub_y+1);

% figure
% plot3(pos_top_arc(:,1),pos_top_arc(:,2),pos_top_arc(:,3),'-or')
% hold on
% plot3(center(:,1),center(:,2),center(:,3),'-xr')
% xlabel('x')
% ylabel('y')
% zlabel('z')

% translate the elevation arc and calculate corners etc.
AngleStep = linspace(StartAngle,StopAngle,nr_sub_x+1);
rect = zeros(nr_sub_y*nr_sub_x,19);
for k = 1:nr_sub_x
    if(k < nr_sub_x/2)
        Angle = AngleStep(k);
    else
        Angle = AngleStep(k+1);
    end
    % translate
    for m = 1:length(z_inner_arc) 
        arcx          = Angle;
        fRad          = z_inner_arc(m);
        x(m)          = fRad * cos(arcx);
        z(m)          = fRad * sin(arcx);
    end
    
    pos_right_arc = [(pos_top_arc(k,1)+x)' y_inner_arc' (pos_top_arc(k,3)-z)'];
    pos_left_arc = [(pos_top_arc(k+1,1)+x)' y_inner_arc' (pos_top_arc(k+1,3)-z)'];
% 
%     plot3(pos_left_arc(:,1),pos_left_arc(:,2),pos_left_arc(:,3))
%     plot3(pos_right_arc(:,1),pos_right_arc(:,2),pos_right_arc(:,3),'r')

    % build corners
    corners = zeros(nr_sub_y,3*4);
    mat_element_center = zeros(nr_sub_y,3);
    for n = 1:nr_sub_y
        corners(n,1:3) = pos_left_arc(n,:);
        corners(n,4:6) = pos_left_arc(n+1,:);
        corners(n,7:9) = pos_right_arc(n+1,:);
        corners(n,10:12) = pos_right_arc(n,:);
        

        mat_element_center(n,:) = (pos_left_arc(n,:)-pos_right_arc(n+1,:))/2+pos_right_arc(n+1,:);
        
%         vert  = [corners(n,1:3);
%                  corners(n,4:6);
%                  corners(n,7:9);
%                  corners(n,10:12)];
%         fac = [1 2 3; 1 3 4];
%         patch('Faces',fac,'Vertices',vert)
        
%         plot3(mat_element_center(n,1),mat_element_center(n,2),mat_element_center(n,3),'ob')
%         plot3(corners(n,1),corners(n,2),corners(n,3),'xr','linewidth',2)
%         plot3(corners(n,4),corners(n,5),corners(n,6),'xb','linewidth',2)
%         plot3(corners(n,7),corners(n,8),corners(n,9),'xk','linewidth',2)
%         plot3(corners(n,10),corners(n,11),corners(n,12),'xg','linewidth',2)

    end
    
    % build rects
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,1) = 0;  % The number for the physical aperture starting from one
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,2:13) = corners;
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,14) = 1; % Apodization value for this element.
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,15) = width; % Width of the element (x direction)    
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,16) = height; % Height of the element (y direction)
    rect(1+(k-1)*nr_sub_y:k*nr_sub_y,17:19) = mat_element_center;

    
end








