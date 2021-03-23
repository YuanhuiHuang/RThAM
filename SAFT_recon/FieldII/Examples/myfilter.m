function sig = myfilter( sig, filter_f, fs )

% Analyze the type of data.
    sais = size(sig);
    dim = find( sais == max(sais) ) ;
    
% Set up the filter coefficents.
if( filter_f(2) ~= 0 )
    f_LPF = filter_f(2) ;
    [b_LPF,a_LPF] = cheby1( 8, .05, 2 * f_LPF/fs * .938 ) ;
end ;

if( filter_f(1) ~= 0 )
    f_HPF = filter_f(1) ;
    if( 2 * f_HPF/fs < 0.016 )
        [b_HPF,a_HPF] = cheby1( 2, .01, 2 * f_HPF/fs * 3.3, 'high' ) ;
    else
        [b_HPF,a_HPF] = cheby1( 4, .01, 2 * f_HPF/fs * 1.46, 'high' ) ;
    end ;
end ;
% % 
%     if( filter_f(2) ~= 0 )
%     f_LPF = filter_f(2) ;
%     [b_LPF,a_LPF] = butter(8, 2 * f_LPF/fs) ;
%     end ;
% 
%     if( filter_f(1) ~= 0 )
%     f_HPF = filter_f(1) ;
%     [b_HPF,a_HPF] = butter(2, 2 * f_HPF/fs, 'high') ;
%     end ;
    
%%
    if (numel(sais) == 3)&&(dim == 3) % SIR with samples in the 3rd dim.
    for ii = 1:sais(1)
        for jj = 1:sais(2)
    

        if( filter_f(2) ~= 0 )
            sig(ii,jj,:) = filtfilt(b_LPF, a_LPF, sig(ii,jj,:)) ;
        end;
        if( filter_f(1) ~= 0 )
            sig(ii,jj,:) = filtfilt(b_HPF, a_HPF, sig(ii,jj,:)) ;
        end;
    
        end
    end
 %%   
    elseif (numel(sais) == 3)&&(dim == 1) % SIR with samples in the 1st dim.
        
            for ii = 1:sais(2)
                for jj = 1:sais(3)
    

                if( filter_f(2) ~= 0 )
                    sig(:,ii,jj) = filtfilt(b_LPF, a_LPF, sig(:,ii,jj)) ;
                end;
                if( filter_f(1) ~= 0 )
                    sig(:,ii,jj) = filtfilt(b_HPF, a_HPF, sig(:,ii,jj)) ;
                end;
    
                end
            end
            
  %%          
    elseif ( numel(sais) == 2 ) && ( ~isvector( sig ) )% sigMat
        
        for ii = 1:sais(2)
            if( filter_f(2) ~= 0 )
                sig(:,ii) = filtfilt(b_LPF, a_LPF, sig(:,ii)) ;
            end;
            if( filter_f(1) ~= 0 )
                sig(:,ii) = filtfilt(b_HPF, a_HPF, sig(:,ii)) ;
            end
        end
    %%    
    elseif isvector(sig) % individual signal.
        
        if( filter_f(2) ~= 0 )
            sig = filtfilt(b_LPF, a_LPF, sig(:)) ;
        end;
        if( filter_f(1) ~= 0 )
            sig = filtfilt(b_HPF, a_HPF, sig(:)) ;
        end
    
    end
    