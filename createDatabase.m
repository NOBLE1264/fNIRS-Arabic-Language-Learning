%% Function to create the database
% Noble C. Amadi

function DB2 = createDatabase(Trad_Day1_data, VR_Day1_data)
    DB2 = struct();
    groups = {'Trad', 'VR'};
    days = {'Day1'};
    datasets = {Trad_Day1_data VR_Day1_data};

    for s = 1:length(groups)
        for d = 1:length(days)
            for participant = 1:6
                for test = 1:8
                    for channel = 1:50
                        [hb_data, hist , freq_spec , Mean , Std, vars] = calculateFeatures(datasets{(s)}{participant, test}, channel);
                        DB2.(groups{s}).(days{d})(participant, test).Delta_HbO_HbR{channel} = hb_data;
                        DB2.(groups{s}).(days{d})(participant, test).IntensityHistogram{channel} = hist;
                        DB2.(groups{s}).(days{d})(participant, test).FrequencySpectrum{channel} = freq_spec;
                        DB2.(groups{s}).(days{d})(participant, test).Mean{channel} = Mean;
                        DB2.(groups{s}).(days{d})(participant, test).StandardDeviation{channel} = Std;
                        DB2.Variables = vars;
                    end
                end
            end
        end
    end
end