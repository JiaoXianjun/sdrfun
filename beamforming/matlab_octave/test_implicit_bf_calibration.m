% SPDX-FileCopyrightText: 2022 Xianjun Jiao putaoshu@msn.com
% SPDX-License-Identifier: AGPL-3.0-or-later

% function test_implicit_bf_calibration
% https://patents.google.com/patent/WO2007103085A2/en
clear all;
close all;

Ntx = 3;
Nrx = 2;

Hab = randn(Nrx, Ntx) + 1i.*randn(Nrx, Ntx);
% r = randn + 1i.*randn;
r=1;
Hba = r.*Hab.';

Atx = diag(randn(Ntx,1) + 1i.*randn(Ntx,1));
Arx = diag(randn(Ntx,1) + 1i.*randn(Ntx,1));
Btx = diag(randn(Nrx,1) + 1i.*randn(Nrx,1));
Brx = diag(randn(Nrx,1) + 1i.*randn(Nrx,1));

Hab_c = Brx*Hab*Atx;
Hba_c = Arx*Hba*Btx;

% Ka = pinv(Hab_c)*(Hba_c.');
Ka = Arx/Atx;
Kb = Brx/Btx;

% Ka = Hba_c/Hab_c.';

Hab_c_k = Hab_c*Ka;
Hba_c_k = Hba_c*Kb;

Hab_c_k
Hba_c_k.'

Hab = randn(Nrx, Ntx) + 1i.*randn(Nrx, Ntx);
Hba = r.*Hab.';

Hab_c = Brx*Hab*Atx;
Hba_c = Arx*Hba*Btx;

Hab_c_k = Hab_c*Ka;
Hba_c_k = Hba_c*Kb;

Hab_c_k
Hba_c_k.'