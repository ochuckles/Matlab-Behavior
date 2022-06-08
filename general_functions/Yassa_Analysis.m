addpath('Q:\Buffalo Lab\eblab\Matlab\get_ALLdata')

clear all
%pack
   
%  TOBII (comment out for other monkeys)
%       filelist=['TO160525.2';'TO160603.2';'TO160606.2';'TO160607.2';'TO160608.2';'TO160609.2';'TO160613.2';'TO160614.2'];
%
%  VIVIAN (comment out for other monkeys)   
%      filelist=['PW160614.2'];%PW160525.3';'PW160608.2';'PW160609.2';'PW160613.2';'PW160615.2';'PW160616.2';'PW160617.2';'PW160620.2';'PW160621.2';'PW160622.2'];
%      Files that need to be checked: PW160607.3 PW160610.2 PW160614.2 PW160623.2
%
%  Manfred (comment out for other monkeys)   
     filelist=['MF160525.2';'MF160607.2';'MF160610.2';'MF160613.2';'MF160615.2'];
%     Files that need to be checked:  MF160614.2 MF160608.2 ;'MF160608.3'
%
%  WILBUR (comment out for other monkeys)   
%    filelist=['WR160503.2';'WR160603.1';'WR160606.1';'WR160613.1';'WR160615.1';'WR160616.1';'WR160620.1';'WR160621.1';'WR160623.1'];    
%     Files that need to be checked: WR160505.2 WR160607.1 WR160608.1
%     WR160609.1 WR160610.1 WR160614.1 WR160622.1
%
%   PEEPERS (comment out for other monkeys)   
%     filelist=['MP160608.2';'MP160610.2';'MP160615.2';'MP160616.2';'MP160622.2';'MP160623.2'];
%     Files that need to be checked: MP160613.2 MP160617.2 MP160620.2 MP160621.2

Cpctyas1=[];
Cpctyas2=[];
Cpctyas3=[];
Cpctyas4=[];
Cpctyas5=[];
Cpctnov6=[];
Pctearlyyas=[];
Pctlure=[];
Cpctfam6=[];
Cpctyasall=[];
EarlyYasvec=[];
LateYasvec=[];
n_yascorvec=[];
n_yasvec=[];


for fillop=1:size(filelist,1);
    fidd=filelist(fillop,:);
    
    ini=fidd(1:2);
   
        
    if strcmp(ini,'MP')==1 || strcmp(ini,'mp')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Peepers\' fidd];
        monkey='Peepers';
    elseif strcmp(ini,'TT')==1 || strcmp(ini,'tt')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Timmy\' fidd];
        monkey='Timmy';
    elseif strcmp(ini,'TO')==1 || strcmp(ini,'to')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Tobii\' fidd];
        monkey='Tobii';
    elseif strcmp(ini,'PW')==1 || strcmp(ini,'pw')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Vivian\' fidd];
        monkey='Vivian';
    elseif strcmp(ini,'WR')==1 || strcmp(ini,'wr')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Wilbur\' fidd];
        monkey='Wilbur';
    elseif strcmp(ini,'RR')==1 || strcmp(ini,'rr')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Red\' fidd];
        monkey='Red';
    elseif strcmp(ini,'MF')==1 || strcmp(ini,'mf')==1
        datfil=['Q:\Buffalo Lab\Cortex Data\Manfred\' fidd];
        monkey='Manfred';        
    end
    
    
    [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);
    
    % Array of all trials that include important information.
    numrpt = size(event_arr,2);
    trl= [];
    for rptlop = 1:numrpt
        %% check if this is the trial that's bad
        %% if fillopp = bad trial day && rptlop = badtrial
        %%      continue;
        %% end
        if ~isempty(find(event_arr(:,rptlop) == 15,1))
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
            nmnumind = find(event_arr(:,rptlop) >=300 & event_arr(:,rptlop) <=399);
            %typnumind = find(event_arr(8,rptlop) >=0) ;
            test6ind= find(event_arr(:,rptlop) == 48);
            respind = find(event_arr(:,rptlop) >= 200 & event_arr(:,rptlop) <= 209);
            cnd       = event_arr(cndnumind,rptlop);
            blk       = event_arr(blknumind,rptlop);
            nm        = event_arr(nmnumind,rptlop)-301;
            typ       = event_arr(8,rptlop);
            test6     = sum(event_arr(test6ind,rptlop))/48;
            resp      = event_arr(respind,rptlop);
            trl = [trl; [cnd blk nm typ test6 resp rptlop]];
        end
    end
    
    % Next three arrays are to parse out those trials that fit either the
    % novel, yassa, or familiar conditions respectively.
    novtrl= [];
    for novlop = 1:numrpt 
        if ~isempty(find(trl(novlop,4) == 6,1))
            trial = trl(novlop,:);
            novtrl = [novtrl; trial];
        end
    end
    
    yastrl= [];
    for yaslop = 1:numrpt
        if ~isempty(find(trl(yaslop,3) == 56,1))
            ytrial = trl(yaslop,:);
            yastrl = [yastrl; ytrial];
        end
    end
    
    famtrl= [];
    for famlop = 1:numrpt
        if ~isempty(find(trl(famlop,4) == 0,1))
            ftrial = trl(famlop,:);
            famtrl = [famtrl; ftrial];
        end
    end
    
    % Attempt to encode the location of each stimuli presentation within
    % the task. Goal is to see where early errors occur, and if ABBA trials
    % influence behavior. Specifically how trials with greater separation
    % in the BB influence success rate.
%     tstnum = []; % Yassa trials only, all diff levels
%     for rptlop = 1:numrpt
%         if ~isempty(find(event_arr(:,rptlop) == 357,1))
%             cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
%             blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
%             test0ind= find(event_arr(:,rptlop) == 23);
%             test1ind= find(event_arr(:,rptlop) == 25);
%             test2ind= find(event_arr(:,rptlop) == 27);
%             test3ind= find(event_arr(:,rptlop) == 29);
%             test4ind= find(event_arr(:,rptlop) == 31);
%             test5ind= find(event_arr(:,rptlop) == 33);
%             test6ind= find(event_arr(:,rptlop) == 48);
%             respind = find(event_arr(:,rptlop) >= 200 & event_arr(:,rptlop) <= 209);
%             cnd       = event_arr(cndnumind,rptlop);
%             typ       = event_arr(8,rptlop);
%             test0     = sum(test0ind);
%             test1     = sum(test1ind);
% %             test2     = sum(event_arr(test2ind,rptlop);
% %             test3     = sum(event_arr(test3ind,rptlop);
% %             test4     = sum(event_arr(test4ind,rptlop);
% %             test5     = sum(event_arr(test5ind,rptlop);
% %             test6     = sum(event_arr(test6ind,rptlop);
%             resp      = event_arr(respind,rptlop);
%             tstnum = [tstnum; [cnd typ test0 test1 resp rptlop]];
%         end
%     end

    
    % Familiar stim trials by number of nonmatch stimuli.
        fam6nm=sum(famtrl(:,3)==6);
        fam5nm=sum(famtrl(:,3)==5);
        fam4nm=sum(famtrl(:,3)==4);
        fam3nm=sum(famtrl(:,3)==3);
        fam2nm=sum(famtrl(:,3)==2);
        fam1nm=sum(famtrl(:,3)==1);
        fam0nm=sum(famtrl(:,3)==0);
        
        Cpctfam6=[Cpctfam6 ((sum(famtrl((famtrl(:,3)==6),6)==200))/fam6nm) *100];
            
     % Novel stim trials
        nov6nm=sum(novtrl(:,3)==6);
        Cpctnov6=[Cpctnov6 ((sum(novtrl((novtrl(:,3)==6),6)==200))/nov6nm) *100];

        nov5nm=sum(novtrl(:,3)==5);
        nov4nm=sum(novtrl(:,3)==4);
        
        % percent correct by trial type, Yassa only. And overall
        % performance on Yassa trial.s
        
        yas1=sum(trl((trl(:,4)==1),6)==200);
        Cpctyas1=[Cpctyas1 yas1/(sum(trl(:,4)==1))*100];
        yas2=sum(trl((trl(:,4)==2),6)==200);
        Cpctyas2=[Cpctyas2 yas2/(sum(trl(:,4)==2))*100];
        yas3=sum(trl((trl(:,4)==3),6)==200);
        Cpctyas3=[Cpctyas3 yas3/(sum(trl(:,4)==3))*100];
        yas4=sum(trl((trl(:,4)==4),6)==200);
        Cpctyas4=[Cpctyas4 yas4/(sum(trl(:,4)==4))*100];
        yas5=sum(trl((trl(:,4)==5),6)==200);
        Cpctyas5=[Cpctyas5 yas5/(sum(trl(:,4)==5))*100];
        Earlyyas=sum(yastrl(:,6)==205);
        EarlyYasvec=[EarlyYasvec sum(Earlyyas)];
        Pctearlyyas=[Pctearlyyas Earlyyas/(sum(yastrl(:,3)==56))*100];
        n_yas=size(yastrl,1);
        n_yasvec=[n_yasvec sum(n_yas)];
        Cpctyasall=[Cpctyasall (sum(yastrl(:,6)==200))/n_yas *100];
        n_yascor=sum(yastrl(:,6)==200);
        n_yascorvec=[n_yascorvec sum(n_yascor)];
        Lateyas=sum(yastrl(:,6)==202);
        LateYasvec=[LateYasvec sum(Lateyas)];

        
        % Yassa trials where the monkey released early and test6 (lure) was
        % turned on.
        
        Yaslure=(sum(yastrl((yastrl(:,6)==205),5)>= 1));
        Pctlure=[Pctlure Yaslure/Earlyyas * 100];
        
end     

% Grouped individual days into overall performance.
n=size((filelist),1);
Yassa1=mean(Cpctyas1);
Yassa2=mean(Cpctyas2);
Yassa3=mean(Cpctyas3);
Yassa4=mean(Cpctyas4);
Yassa5=mean(Cpctyas5);
Novel6=mean(Cpctnov6);
AllYassa=mean(Cpctyasall);
Familiar6=mean(Cpctfam6);
PercentLure=mean(Pctlure);
AllYasstd=std(Cpctyasall);
Fam6std=std(Cpctfam6);
Nov6std=std(Cpctnov6);
Lurestd=std(Pctlure);
Yas1std=std(Cpctyas1);
Yas2std=std(Cpctyas2);
Yas3std=std(Cpctyas3);
Yas4std=std(Cpctyas4);
Yas5std=std(Cpctyas5);
AllYasSE=AllYasstd/sqrt(n);
Fam6SE=Fam6std/sqrt(n);
Nov6SE=Nov6std/sqrt(n);
LureSE=Lurestd/sqrt(n);
Yas1SE=Yas1std/sqrt(n);
Yas2SE=Yas2std/sqrt(n);
Yas3SE=Yas3std/sqrt(n);
Yas4SE=Yas4std/sqrt(n);
Yas5SE=Yas5std/sqrt(n);
AllYasEarly=sum(EarlyYasvec);
AllYasLate=sum(LateYasvec);
AllYasCor=sum(n_yascorvec);
N_AllYas=sum(n_yasvec);
N_YasOther=N_AllYas-(AllYasCor + AllYasLate + AllYasEarly);
y=[Cpctyas1;Cpctyas2;Cpctyas3;Cpctyas4;Cpctyas5;Cpctnov6;Cpctfam6];
%%
%Convert y into a Nx1 vector, and assign groups to each data point
[n_cat,n_rep]=size(y);
cat=1:n_cat;
cat=cat';
X=repmat(cat,n_rep,1);
y=y(:); 
%y=array2table(y);
% y=reshape(y,[48,1]);
%  groups = {'Lvl1'; 'Lvl1'; 'Lvl1'; 'Lvl1'; 'Lvl1'; 'Lvl1'; 'Lvl1'; 'Lvl1'; ...
%       'Lvl2'; 'Lvl2'; 'Lvl2'; 'Lvl2'; 'Lvl2'; 'Lvl2'; 'Lvl2'; 'Lvl2'; ... 
%       'Lvl3'; 'Lvl3'; 'Lvl3'; 'Lvl3'; 'Lvl3'; 'Lvl3'; 'Lvl3'; 'Lvl3'; ...
%       'Lvl4'; 'Lvl4'; 'Lvl4'; 'Lvl4'; 'Lvl4'; 'Lvl4'; 'Lvl4'; 'Lvl4'; ...
%       'Lvl5'; 'Lvl5'; 'Lvl5'; 'Lvl5'; 'Lvl5'; 'Lvl5'; 'Lvl5'; 'Lvl5'; ...
%       'Nov6'; 'Nov6'; 'Nov6'; 'Nov6'; 'Nov6'; 'Nov6'; 'Nov6'; 'Nov6'};
%%

        
 % Figures
    
        Yaspct=[Yassa1; Yassa2; Yassa3; Yassa4; Yassa5; Novel6]; 
        YasSE=[Yas1SE; Yas2SE; Yas3SE; Yas4SE; Yas5SE; Nov6SE];
    figure;
    bar(Yaspct, 'grouped');
    hold on
    errorbar(Yaspct, YasSE)  
    box off
    set(gca,'XTickLabel',{'Lvl1';'Lvl2';'Lvl3';'Lvl4';'Lvl5';'Nov6'}); ylabel('Percent Correct +/- SEM'); title(monkey)
    
%     figure;
%     plotmatrix(y)
%     hold on
%     box off
    
        Allpct=[AllYassa; Novel6; Familiar6];
        AllSE=[AllYasSE; Nov6SE; Fam6SE];
    figure;
    bar(Allpct, 'grouped');
    hold on
    errorbar(Allpct, AllSE)
    box off
    set(gca,'XTickLabel',{'Yassa';'Novel 6NM';'Familiar 6NM'}); ylabel('Percentage Correct +/- SEM'); title(monkey)

    figure;
    boxplot([Cpctyasall(:),Cpctnov6(:),Cpctfam6(:)])
    hold on 
    box off
    set(gca,'XTickLabel',{'All Yassa';'Novel 6NM';'Familiar 6NM'}); ylabel('Percent Correct'); title(monkey)

    figure;
    N_graph=[N_AllYas; AllYasCor; AllYasEarly; AllYasLate];
    bar(N_graph, 'grouped');
    hold on
    box off
    set(gca,'XTickLabel',{['All PS (',num2str(N_AllYas),')'];['Correct (',num2str(AllYasCor),')'];['Early (',num2str(AllYasEarly),')'];['Late (',num2str(AllYasLate),')']}); ylabel('Number of Trials'); title(monkey)
%%        
% Statistical Tests

[p,stats]=vartestn(y,X,'TestType', 'LeveneAbsolute');

[p,table,stats] = anova1(y,X);


[h,p,ci,stats]=ttest2(Cpctfam6,Cpctyasall)

%[p,tbl,stats] = mixedmodelANOVA(y,subject)