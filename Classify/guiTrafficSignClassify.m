function varargout = guiTrafficSignClassify(varargin)
% GUITRAFFICSIGNCLASSIFY MATLAB code for guiTrafficSignClassify.fig
%      GUITRAFFICSIGNCLASSIFY, by itself, creates a new GUITRAFFICSIGNCLASSIFY or raises the existing
%      singleton*.
%
%      H = GUITRAFFICSIGNCLASSIFY returns the handle to a new GUITRAFFICSIGNCLASSIFY or the handle to
%      the existing singleton*.
%
%      GUITRAFFICSIGNCLASSIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUITRAFFICSIGNCLASSIFY.M with the given input arguments.
%
%      GUITRAFFICSIGNCLASSIFY('Property','Value',...) creates a new GUITRAFFICSIGNCLASSIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiTrafficSignClassify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiTrafficSignClassify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiTrafficSignClassify

% Last Modified by GUIDE v2.5 26-Oct-2017 10:44:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiTrafficSignClassify_OpeningFcn, ...
                   'gui_OutputFcn',  @guiTrafficSignClassify_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guiTrafficSignClassify is made visible.
function guiTrafficSignClassify_OpeningFcn(hObject, eventdata, handles, varargin)
set(findobj(gcf, 'type','axes'), 'Visible','off')
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiTrafficSignClassify (see VARARGIN)

% Choose default command line output for guiTrafficSignClassify
handles.output = hObject;
load('vectorPropio.mat')
load('valorPropio.mat')
% Se cargan las etiquetas de las se�ales de tr�nsito
load('labels.mat')
% Se cargan los datos de entrenamiento del modelo, extra�dos de las
% im�genes de la base de datos
load('HOGFeatures.mat');
load('clases.mat');
Xtrain = caracteristicas;
handles.Ytrain = clases;
handles.labels = labels
handles.vectorPropio = vectorPropio
handles.valorPropio = valorPropio

porcentaje = 0;
x=0;
% Con el m�todo PCA se ordenan descendentemente las caracter�sticas con
% mayor peso, se establece un margen de 0.90 para tomar la caracter�sticas
% a ser usadas entre el total extra�das por HOG
while porcentaje<0.90
    x=x+1;
    porcentaje = porcentaje + (valorPropio(x)/sum(valorPropio));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se seleccionan las caracter�sticas de las muestras de entrenamiento
% y la que se quiere evaluar, correspondientes a las caracter�sticas
% seleccionadas por el c�lculo en el valor propio
handles.Xtrain = Xtrain*vectorPropio(:,1:x);
handles.x=x;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes guiTrafficSignClassify wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiTrafficSignClassify_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in classifyBtn.
function classifyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to classifyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic;
[Xtrain, mu, sigma] = zscore(handles.Xtrain);
Xtest = (handles.Xtest-repmat(mu,size(handles.Xtest,1),1))./repmat(sigma,size(handles.Xtest,1),1);
[classification] = classify(Xtest, Xtrain, handles.Ytrain, 'linear');
text = ['La se�al de tr�nsito es: ',handles.labels{classification}];
set(handles.classifyText,'String',text);
disp(text);
text2 = ['./SampleSigns/',num2str(classification),'.png'];
img2 = imread(text2);
axes(handles.result_img);
imshow(img2);
toc;



% --- Executes on button press in importBtn.
function importBtn_Callback(hObject, eventdata, handles)
% hObject    handle to importBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname]=uigetfile({'*.jpg;*.jpeg;*.jp2;*.jpf;*.jpx;*.j2c;*.j2k;*.ppm;*.png;*.bmp;*.tiff;*.tif;*.ico;*.pnm'},'Select An Image');
fullPath = strcat(pathname,filename);
img = imread(fullPath);
img = imresize(img, [300 300]);
axes(handles.import_img);
imshow(img);
[Xsample, ~] = extractHOGFeatures(img);
handles.Xtest = Xsample*handles.vectorPropio(:,1:handles.x);

guidata(hObject, handles);
