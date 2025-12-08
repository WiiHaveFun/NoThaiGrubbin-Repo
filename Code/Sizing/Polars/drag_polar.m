classdef drag_polar
    % POLAR Drag polar that calculates CD0 and e
    %   Detailed explanation goes here

    properties
        ac
        flap string {mustBeMember(flap, ["no", "half", "full"])}
        gear logical
        tanks logical
        hook logical
        pp
        Mcrit
        MDD
    end

    methods
        function obj = drag_polar(ac, flap, gear, tanks, hook)
            % POLAR Construct an instance of this class
            %   Detailed explanation goes here
            obj.ac = ac;
            obj.flap = flap;
            obj.gear = gear;
            obj.tanks = tanks;
            obj.hook = hook;
            [obj.pp, obj.Mcrit, obj.MDD] = transonic_spline(ac.initial.Sref, ...
                                                   ac.sup.Amax, ... % TODO
                                                   ac.sup.l, ... % TODO
                                                   ac.sup.Ewd, ... % TODO
                                                   ac.initial.sweep_le, ...
                                                   ac.initial.tc, ...
                                                   ac.initial.sweep_c4, ...
                                                   ac.initial.CL_cruise); % TODO
        end

        function [CD0, CDf, CDmisc, CDw, CDlp, CDflap] = get_CD0(obj, h, M)
            % Skin friction components
            l = [obj.ac.initial.MAC
                 obj.ac.initial.MAC_HT
                 obj.ac.initial.MAC_VT
                 obj.ac.initial.l_fus % TODO
                 obj.ac.initial.l_canopy % TODO
                 obj.ac.initial.l_tanks % TODO
                 obj.ac.initial.l_pylon]; % TODO
            Cf = turb_cf(h, l, M);
            if M <= obj.MDD
                FF = [wing_ff(obj.ac.initial.xc_m, obj.ac.initial.tc, M, obj.ac.initial.sweep_m)
                      wing_ff(obj.ac.initial.xc_m_HT, obj.ac.initial.tc_HT, M, obj.ac.initial.sweep_m_HT)
                      1.1 .* wing_ff(obj.ac.initial.xc_m_VT, obj.ac.initial.tc_VT, M, obj.ac.initial.sweep_m_VT)
                      fus_ff(l(4), obj.ac.initial.Amax_fus) % TODO
                      fus_ff(l(5), obj.ac.initial.Amax_canopy)
                      ext_ff(l(6), obj.ac.initial.Amax_tanks)
                      ext_ff(l(7), obj.ac.initial.Amax_pylon)]; % TODO
                Q = [1
                     1.05
                     1.05
                     1
                     1
                     1.3
                     1.5];
            else
                FF = ones(size(l));
                Q = ones(size(l));
            end

            if M > obj.MDD && M < 1.2
                [~, CDf_1, ~, ~, ~] = get_CD0(obj, h, obj.MDD);
                [~, CDf_2, ~, ~, ~] = get_CD0(obj, h, 1.2);

                CDf = interp1([obj.MDD, 1.2], [CDf_1, CDf_2], M);
            else
                % TODO
                Swet = [obj.ac.initial.Swet_wing
                        obj.ac.initial.Swet_HT
                        obj.ac.initial.Swet_VT
                        obj.ac.initial.Swet_fus
                        obj.ac.initial.Swet_canopy
                        obj.ac.initial.num_drop_tanks .* obj.ac.initial.Swet_tanks
                        obj.ac.initial.num_drop_tanks .* obj.ac.initial.Swet_pylon];

                if ~obj.tanks
                    Swet(6) = 0;
                    Swet(7) = 0;
                end

                CDf = sum(Cf .* FF .* Q .* Swet) ./ obj.ac.initial.Sref;
            end

            % Miscellaneous
            CDpi_wheel = 0.25;
            CDpi_strut = 0.30;
            Dq_nw = obj.ac.gear.N_nw .* CDpi_wheel .* obj.ac.gear.A_nw; % TODO areas
            Dq_ng = CDpi_strut .* obj.ac.gear.A_ng;
            Dq_mw = 2 .* CDpi_wheel .* obj.ac.gear.A_mw;
            Dq_mg = 2 .* CDpi_strut .* obj.ac.gear.A_mg;
            CDgear = (Dq_nw + Dq_ng + Dq_mw + Dq_mg) ./ obj.ac.initial.Sref ...
                     .* 1.2 .* 1.07;

            CDhook = 0.009 ./ obj.ac.initial.Sref;
            CDmisc = 0;
            if obj.gear
                CDmisc = CDmisc + CDgear;
            end
            if obj.hook
                CDmisc = CDmisc + CDhook;
            end

            % Wave drag
            if M >= 1.2
                CDw = wave_cd(obj.ac.initial.Sref, ...
                              obj.ac.sup.Amax, ...
                              obj.ac.sup.l, ...
                              obj.ac.sup.Ewd, ...
                              M, ...
                              obj.ac.initial.sweep_le);
            elseif M > obj.Mcrit
                CDw = ppval(obj.pp, M);
            else
                CDw = 0;
            end
            
            CD0 = CDf + CDmisc + CDw;

            % Leakages and Protuberance
            CD0 = CD0 ./ 0.95; % 5% of total CD0
            CDlp = CD0 * 0.05;

            % Flaps
            Fplain = 0.0144; % Plain
            Fslotted = 0.0074; % Slotted
            CDflap = 0;
            switch obj.flap
                case "half"
                    CDflap = CDflap + flap_cd(Fplain, ...
                                              obj.ac.initial.CfC_le, ...
                                              obj.ac.initial.SfS_le, ...
                                              obj.ac.initial.dflap_le ./ 2);
                    CDflap = CDflap + flap_cd(Fslotted, ...
                                              obj.ac.initial.CfC_tein, ...
                                              obj.ac.initial.SfS_tein, ...
                                              obj.ac.initial.dflap_te ./ 2);
                    CDflap = CDflap + flap_cd(Fslotted, ...
                                              obj.ac.initial.CfC_teout, ...
                                              obj.ac.initial.SfS_teout, ...
                                              obj.ac.initial.dflap_te ./ 2);
                case "full"
                    CDflap = CDflap + flap_cd(Fplain, ...
                                              obj.ac.initial.CfC_le, ...
                                              obj.ac.initial.SfS_le, ...
                                              obj.ac.initial.dflap_le);
                    CDflap = CDflap + flap_cd(Fslotted, ...
                                              obj.ac.initial.CfC_tein, ...
                                              obj.ac.initial.SfS_tein, ...
                                              obj.ac.initial.dflap_te);
                    CDflap = CDflap + flap_cd(Fslotted, ...
                                              obj.ac.initial.CfC_teout, ...
                                              obj.ac.initial.SfS_teout, ...
                                              obj.ac.initial.dflap_te);
            end

            CD0 = CD0 + CDflap;
        end

        function K = get_K(obj, M)
            AR = obj.ac.initial.AR;
            lambda_le = obj.ac.initial.sweep_le;
            if M < obj.Mcrit
                e = 4.61 .* (1 - 0.045.*AR.^0.68) .* cos(lambda_le).^0.15 - 3.1;
            elseif M > 1.2
                K = AR.*(M.^2 - 1).*cos(lambda_le) ./ (4.*AR.*sqrt(M.^2 - 1) - 2);
                e = 1 ./ (pi.*AR.*K);
                e = max(e, 0.3);
            else
                e1 = 4.61 .* (1 - 0.045.*AR.^0.68) .* cos(lambda_le).^0.15 - 3.1;
                K2 = AR.*(1.2.^2 - 1).*cos(lambda_le) ./ (4.*AR.*sqrt(1.2.^2 - 1) - 2);
                e2 = 1 ./ (pi.*AR.*K2);

                e = spline([obj.Mcrit 1.2], [0, e1, e2, 0], M);
            end

            switch obj.flap
                case "half"
                    e = e - 0.032;
                case "full"
                    e = e - 0.046;
            end
            K = 1 ./ (pi.*AR.*e);

            % Trim correction
            K = K .* 1.05;
        end

        function CLmax = get_CLmax(obj)
            switch obj.flap
                case "no"
                    CLmax = 0.79;
                case "half"
                    CLmax = 1.105;
                case "full"
                    CLmax = 1.42;
            end
        end

        function plot_CD0(obj, h)
            M = linspace(0.001, 2.0, 1000);

            CDf = zeros(size(M));
            CDmisc = zeros(size(M));
            CDw = zeros(size(M));
            CDlp = zeros(size(M));
            CDflap = zeros(size(M));

            for i = 1:length(M)
                [CD0(i), CDf(i), CDmisc(i), CDw(i), CDlp(i), CDflap(i)] = get_CD0(obj, h, M(i));
            end

            CD_vec = [CDf; CDmisc; CDflap; CDlp; CDw];
            CD_plot = cumsum(CD_vec, 1);

            plot(M, CD_plot(1, :));
            hold on;
            plot(M, CD_plot(2, :), "--");
            plot(M, CD_plot(3, :), "-.");
            plot(M, CD_plot(4, :));
            plot(M, CD_plot(5, :));
        end

        function plot_polar(obj, h, M, varargin)
            CD0 = get_CD0(obj, h, M);
            K = get_K(obj, M);
            CLmax = get_CLmax(obj);

            CL = linspace(0, CLmax, 100);
            CD = CD0 + K .* CL.^2;
            plot(CD, CL, varargin{:});
        end
    end
end