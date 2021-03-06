function varargout = guiTrafficSignClassify(varargin)
%
%   Description for Matlab GUI implemented in guiTrafficSignClassify:
%
%       GUITRAFFICSIGNCLASSIFY MATLAB code for guiTrafficSignClassify.fig
%           GUITRAFFICSIGNCLASSIFY, by itself, creates a new GUITRAFFICSIGNCLASSIFY or raises the existing
%           singleton*.
%
%           H = GUITRAFFICSIGNCLASSIFY returns the handle to a new GUITRAFFICSIGNCLASSIFY or the handle to
%           the existing singleton*.
%
%           GUITRAFFICSIGNCLASSIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%           function named CALLBACK in GUITRAFFICSIGNCLASSIFY.M with the given input arguments.
%
%           GUITRAFFICSIGNCLASSIFY('Property','Value',...) creates a new GUITRAFFICSIGNCLASSIFY or raises the
%           existing singleton*.  Starting from the left, property value pairs are
%           applied to the GUI before guiTrafficSignClassify_OpeningFcn gets called.  An
%           unrecognized property name or invalid value makes property application
%           stop.  All inputs are passed to guiTrafficSignClassify_OpeningFcn via varargin.
%
%           *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%           instance to run (singleton)".
%
%       See also: GUIDE, GUIDATA, GUIHANDLES
%
%	Description for application implemented inside the GUI:
%
%       GUITRAFFICSIGNCLASSIFY implements a traffic sign classificator using
%       Histogram of Oriented Gradients for characteristics extraction, 
%       Principal Component Analysis for characteristics reduction and
%       Gaussian Mixture Model for classification.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inicializaci�n de las variables y componentes usados en el clasificador %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
% Se asignan los datos importados a variables globales
handles.Xtrain = Xtrain;
handles.Ytrain = clases;
handles.labels = labels;
handles.vectorPropio = vectorPropio;
handles.valorPropio = valorPropio;

porcentaje = 0;
x=0;
% Con el m�todo PCA se ordenan descendentemente las caracter�sticas con
% mayor peso, se establece un margen de 0.90 para tomar la caracter�sticas
% a ser usadas entre el total extra�das por HOG
while porcentaje<0.90
    x=x+1;
    porcentaje = porcentaje + (valorPropio(x)/sum(valorPropio));
end
% Se seleccionan las caracter�sticas de las muestras de entrenamiento
% y la que se quiere evaluar, correspondientes a las caracter�sticas
% seleccionadas por el c�lculo en el valor propio
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Realizar la clasificaci�n de la imagen %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Se ejecuta al presionar el bot�n Classify.
function classifyBtn_Callback(hObject, eventdata, handles)
tic;
% Se normalizan las muestras para evitar que haya polarizaci�n en los
% datos debido a la diferencia en los valores, tambi�n se encuentran media
% y desviaci�n est�ndar de los datos
[Xtrain, mu, sigma] = zscore(handles.Xtrain);
Xtest = (handles.Xtest-repmat(mu,size(handles.Xtest,1),1))./repmat(sigma,size(handles.Xtest,1),1);
% Se entrena el modelo de predicci�n como un modelo de mezclas gaussianas
% utilizando los datos de las muestras de entrenamiento, y se muestra el
% valor de la evaluaci�n de la muestra que se quiere clasificar
[classification] = classify(Xtest, Xtrain, handles.Ytrain, 'linear');
% Se selecciona el nombre de la muestra seg�n la clasificaci�n hecha y se
% muestra en la etiqueta correspondiente
text = ['La se�al de tr�nsito es: ',handles.labels{classification}];
set(handles.classifyText,'String',text);
disp(text);
% Se elige cu�l es la se�al de tr�nsito del banco de im�genes de las
% se�ales y se muestra en el lado derecho de la ventana
text2 = ['./SampleSigns/',num2str(classification),'.png'];
img2 = imread(text2);
axes(handles.result_img);
imshow(img2);
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Seleccionar la imagen a ser clasificada %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Se ejecuta al proesionar el bot�n Import image.
function importBtn_Callback(hObject, eventdata, handles)
% hObject    handle to importBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Importar una imagen seleccionada por el usuario
[filename, pathname]=uigetfile({'*.jpg;*.jpeg;*.jp2;*.jpf;*.jpx;*.j2c;*.j2k;*.ppm;*.png;*.bmp;*.tiff;*.tif;*.ico;*.pnm'},'Select An Image');
% Obtener la ruta absoluta de la imagen
fullPath = strcat(pathname,filename);
% Importar la imagen como una variable
img = imread(fullPath);
% Redimensi�n de la imagen
img = imresize(img, [300 300]);
% Establecer el marco donde estar� ubicada la imagen a ser clasificada
axes(handles.import_img);
imshow(img);
% Se extraen las caracter�sticas del histograma de vectores de soporte
[Xsample, ~] = extractHOGFeatures(img);
% Se extraen las caracter�sticas por PCA de la imagen a ser clasificada
handles.Xtest = Xsample*handles.vectorPropio(:,1:handles.x);
cla(handles.result_img,'reset');
set(handles.classifyText,'String','');
% Se exportan a la clase global los datos que resultan de esta funci�n
guidata(hObject, handles);
