function Pm_ROIPosition = Pm_selectROI(PmVid,himage,ROI_Edit)
%% v1.0 yuanhui 20190220
% PVCam_selectROI(PMvid1,'Full'); % 'Full', 'Half', 'Manual', 'Keep'
if nargin == 2
    ROI_Edit = questdlg('Select ROI in frame of pixels', ...
        'ROI select or edit', ...
        'Full','Half','Manual','Full');
end

switch ROI_Edit
    case 'Full'
        Pm_ROIPosition = [0 0 2048 2048];
        PmVid.ROIPosition = Pm_ROIPosition; % set FOV; for CMOS no need to trim horizontal
    case 'Half'
        Pm_ROIPosition = [0 512 2048 1024];
        PmVid.ROIPosition = Pm_ROIPosition; % set FOV; for CMOS no need to trim horizontal
    case 'Manual'
        Pm_ROIPosition = myRectROI(himage);
        PmVid.ROIPosition = Pm_ROIPosition; % select FOV; for CMOS no need to trim horizontal
    otherwise 
        disp('Not changing');
        Pm_ROIPosition = PmVid.ROIPosition; 
end