	function MAT2TIFF(Recon_bp3D0, name)
% function to write MATRIX to tiff
% @Recon_bp3D - 3D matrix to write to file
% @name - filename

outputFileName = [name,'.tif'];

minimum=min(Recon_bp3D0(:));
maximum=max(Recon_bp3D0(:)-minimum);
Recon_bp3D0=Recon_bp3D0-minimum;
numrows = size(Recon_bp3D0,1);
numcols = size(Recon_bp3D0,2);

for k=1:size(Recon_bp3D0,3)
    t = Tiff(outputFileName,'a');
    t.setTag('Photometric',Tiff.Photometric.MinIsBlack);
    t.setTag('Compression',Tiff.Compression.None);
    t.setTag('BitsPerSample',32);
    t.setTag('SamplesPerPixel',1);
    t.setTag('SampleFormat',Tiff.SampleFormat.UInt);
    t.setTag('ExtraSamples',Tiff.ExtraSamples.Unspecified);
    t.setTag('ImageLength',numrows);
    t.setTag('ImageWidth',numcols);
    t.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
    AA = squeeze(Recon_bp3D0(:,:,k));    
%     AA = AA-minimum;
    X32 = uint32(AA/maximum*(2^32-1));
    t.write(X32);

end

    t.close();
    
disp('----------DONE----------')

end

