
for zSteps=6.40:0.02:6.50 % mm
    
[S_, z_] = acquiereMScanGaGe_stack(pi,DAQ,zSteps);

end

h = get(0,'children');
for i=1:length(h)
  saveas(h(i), ['figure' num2str(i)], 'fig');
end
