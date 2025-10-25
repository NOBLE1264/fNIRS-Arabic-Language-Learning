function NaNChans = getNaNChannels(NormDATA, feat)
    %--- Check features ---
    assert( ismember(feat, {'FS','IH','MS'}), ...
            'feat must be ''FS'', ''IH'' or ''MS''.' );

    conds     = fieldnames(NormDATA);
    groups    = {'Trad','VR'};
    hemoTypes = {'HbO','HbR'};

    for iC = 1:numel(conds)
        cName = conds{iC};

        % infer #channels from Trad.HbO
        nCh = size(NormDATA.(cName).Trad.HbO, 2);

        for h = 1:2
            ht   = hemoTypes{h};
            mask = false(1, nCh);

            for c = 1:nCh
                % check Trad first, then VR
                for g = 1:2
                    grp = groups{g};
                    C   = NormDATA.(cName).(grp).(ht);  % nSubs×nCh cell
                    nSubs = size(C,1);

                    % does *any* subject have *any* NaN in this channel?
                    for p = 1:nSubs
                        if any( isnan( C{p,c} ) )
                            mask(c) = true;
                            break
                        end
                    end
                    if mask(c)
                        break  % no need to check VR if Trad already bad
                    end
                end
            end

            % store bad channel indices for this hemotype
            NaNChans.(cName).(ht) = find(mask);
        end
    end
end
