import struct 
import os
import unittest
import subprocess
from __main__ import vtk, qt, ctk, slicer
from slicer.ScriptedLoadableModule import *
import numpy
import re
import json	
import httplib

#
# DEETO
#
"""Uses ScriptedLoadableModule base class, available at:
https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
"""


class DEETO(ScriptedLoadableModule):

  def __init__(self, parent):
    ScriptedLoadableModule.__init__(self, parent)
    self.parent.title = "DEETO" # TODO make this more human readable by adding spaces
    self.parent.categories = ["Segmentation"]
    self.parent.dependencies = []
    self.parent.contributors = ["Gabriele Arnulfo (Univ. Genoa) & Massimo Narizzano (Univ. Genoa)"]
    self.parent.helpText = """
    seeg electroDE rEconstruction TOol (DEETO):
        This tool reconstructs the position of SEEG electrode contacts from a post-implant Cone-beam CT scan.
    """
    self.parent.acknowledgementText = """
    This file was originally developed by Gabriele Arnulfo & Massimo Narizzano
    """ 

###############
# DEETOWidget #
###############
class DEETOWidget(ScriptedLoadableModuleWidget):
  def setup(self):
    ScriptedLoadableModuleWidget.setup(self)
    #### Struttura dati per il layout dinamico
    self.ECRows = []
    self.comboRows = []
    self.tailCheckBox = []
    self.headCheckBox = []
    self.hideCheckBox = []
    self.electrodeNames = []
    #[TODO]
    self.lutPath = os.path.join(slicer.app.slicerHome,'share/FreeSurfer/FreeSurferColorLUT20120827.txt')
    ### Setup del layout dei vari step
    ### Step 1 : set up delle variabili
    self.setupSetup()
    ### Step 2 : caricamento del fiducial list
    self.setupLoadFiducials()
    ### Step 3 : Configurazione degli elettrodi
    self.setupElectrodeConfiguration()
    ### Step 4 : Segmentazione
    self.setupSegmentation()
    ### Step 5 : Zone Detection 
    self.setupZoneDetection()
    ### Step 6 : Xtens 
#    self.setupXtensIntegration()
    ####[TODO] bisogna farlo leggere da file di configurazione 
    self.models = {'default' : [18,2.0,0.8,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5],\
                   'cinque' :[15,2.0,0.8,1.5,1.5,1.5,1.5,10.5,1.5,1.5,1.5,1.5,10.5,1.5,1.5,1.5,1.5],\
                   'default15' : [15,2.0,0.8,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5],\
                   'default12' : [12,2.0,0.8,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5],\
                   'default10' : [10,2.0,0.8,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5], \
                   'default9' : [9,2.0,0.8,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5],\
                   'default5' : [5,2.0,0.8,1.5,1.5,1.5,1.5,1.5]}

    self.progBar = qt.QProgressBar()
    self.progBar.setTextVisible(False)

    self.layout.addWidget(self.progBar)


###################################################
#### 1. Setup della prima parte dell'interfaccia
#### In questa parte creiamo l'interfaccia di tutti
#### Quei parametri per il set up
###################################################
  def setupSetup(self):
    #### Creazione del bottone collapsible
    self.setupCB = ctk.ctkCollapsibleButton()
    self.setupCB.text = "Step 1 : Configurations"
    #### Menu di set up aggiunto alla form globale
    self.layout.addWidget(self.setupCB)
    #### Creo un layout per questa paste
    self.setupFormLayout = qt.QFormLayout(self.setupCB)
    #### Bottone
    self.deetoB = qt.QToolButton()
    self.deetoB.setText("...")
    self.deetoB.toolTip = "Change deeto executable"
    self.deetoB.enabled = True
    self.deetoB.connect('clicked(bool)', self.onDeetoButton)

    #### Execution Line
    deetoPath = os.path.dirname(slicer.modules.DEETOInstance.parent.path)
    deetoExec = '../bin/deeto'

    self.deetoE = qt.QLineEdit(deetoExec)
    self.deetoE.setDisabled(True)
    self.deetoE.setMaximumWidth(100)
    self.deetoE.setFixedWidth(400)
    
    self.dialog = qt.QFileDialog()
    self.dialog.setFileMode(qt.QFileDialog.AnyFile)
    self.dialog.setToolTip( "Pick the input to the algorithm." )

    #### deeto button layout
    self.deetoExecLayout = qt.QHBoxLayout()
    self.deetoExecLayout.addWidget(self.deetoE)
    self.deetoExecLayout.addWidget(self.deetoB)
    #### Aggiungo il bottone al layout
    self.setupFormLayout.addRow("DEETO executable: ", self.deetoExecLayout)
    
    #### TODO: connettere il bottone deetoB con una qualche logica.
    
##################################################################################

###################################################
#### 2. Setup della seconda parte dell'interfaccia In questa parte
#### creiamo l'interfaccia per caricare il fiducial list.
###################################################
  def setupLoadFiducials(self):
    self.loadfidsCB = ctk.ctkCollapsibleButton()
    self.loadfidsCB.text = "Step 2 : Load Fiducials"
    #### Creo un layout per questa parte
    self.loadFidsLayout = qt.QFormLayout(self.loadfidsCB) 
    self.innerLayout = qt.QHBoxLayout()

    #### Select box a tendina fidsSelector
    self.fidsSelector = slicer.qMRMLNodeComboBox()
    self.fidsSelector.nodeTypes = ( ("vtkMRMLMarkupsFiducialNode"), "" )
    self.fidsSelector.selectNodeUponCreation = False
    self.fidsSelector.addEnabled = False
    self.fidsSelector.removeEnabled = False
    self.fidsSelector.noneEnabled = True
    self.fidsSelector.setMRMLScene( slicer.mrmlScene )
    self.fidsSelector.setToolTip("Select a fiducial list")


    self.loadButton = qt.QPushButton("Load")
    self.loadButton.toolTip = "Load Markups for Electrode Configuration"
    self.loadButton.enabled = True

    #### Aggiungo il bottone al layout
    self.innerLayout.addWidget(self.fidsSelector)
    self.innerLayout.addWidget(self.loadButton)

    self.loadFidsLayout.addRow("Fiducial :",self.innerLayout)
    self.layout.addWidget(self.loadfidsCB)

    # - connect Load button alla funzione onLoadButton
    self.loadButton.connect('clicked(bool)', self.onLoadButton)


##################################################################################

###################################################
#### 3. Setup della terza parte. Qui creiamo l'interfaccia Per modificare
#### i parametri di configurazione degli elettrodi. In modo dinamico
#### per ogni elettrodo vengono creati dei pulsanti particolari
###################################################
  def setupElectrodeConfiguration(self):
    self.configurationCB = ctk.ctkCollapsibleButton()
    self.configurationCB.text = "Step 3 : Electrodes Configuration"
    self.layout.addWidget(self.configurationCB)
    self.configurationCBLayout = qt.QVBoxLayout(self.configurationCB)
    electrodes = []
    self.loadElectrodeConfiguration(electrodes)
    
  def loadElectrodeConfiguration(self,electrodes):
#    print("A " + str(len(electrodes)))
#    print("B " + str(self.configurationCBLayout.count()))
    names = ["Name","Type/Model","Tail","Head","Hide"]
    hsize  = [80,150,50,50,50]

    if len(electrodes) > 0 :
      if (self.configurationCBLayout.count() < 1):
        self.intestazioneGroupBox = qt.QGroupBox(self.configurationCB)
        self.hlayout = qt.QHBoxLayout(self.intestazioneGroupBox)
        self.hlayout.setMargin(1)
        for i in (xrange(len(names))):
          a = qt.QLabel(names[i],self.intestazioneGroupBox)
          a.setMaximumWidth(hsize[i])
          a.setMaximumHeight(20)
          a.setStyleSheet("qproperty-alignment: AlignCenter;")
          self.hlayout.addWidget(a)

        self.configurationCBLayout.addWidget(self.intestazioneGroupBox)
      self.ECRows = []
      self.comboRows = []
      self.tailCheckBox = []
      self.headCheckBox = []
      self.hideCheckBox = []

      print(self.configurationCBLayout.count())
      chiavi = self.models.keys()
      for i in (xrange(len(electrodes))):
        ####### Riga
        ### Crea grouppo (una riga)
        self.ECRows.append(qt.QGroupBox(self.configurationCB))
        self.hlayout = qt.QHBoxLayout(self.ECRows[i])
        self.hlayout.setMargin(1)
        ### Label nome elettrodo
        a = qt.QLabel(electrodes[i],self.ECRows[i])
        a.setMaximumWidth(hsize[0])
        self.hlayout.addWidget(a)
        ### ComboBox
        self.comboRows.append(qt.QComboBox(self.ECRows[i]))
        for k in chiavi :
          self.comboRows[i].addItem(k)
        self.comboRows[i].setMaximumWidth(hsize[1])
        self.comboRows[i].setMaximumHeight(20)
        self.comboRows[i].setStyleSheet("qproperty-alignment: AlignCenter;")
        self.hlayout.addWidget(self.comboRows[i])
        ### Tail CheckBox
        self.tailCheckBox.append(qt.QCheckBox(self.ECRows[i]))
        self.tailCheckBox[i].setMaximumWidth(hsize[2])
        self.tailCheckBox[i].setMaximumHeight(20)
        self.tailCheckBox[i].setStyleSheet("qproperty-alignment: AlignCenter;")
        self.hlayout.addWidget(self.tailCheckBox[i])
        ### Head CheckBox
        self.headCheckBox.append(qt.QCheckBox(self.ECRows[i]))
        self.headCheckBox[i].setMaximumWidth(hsize[3])
        self.headCheckBox[i].setMaximumHeight(20)
        self.headCheckBox[i].setStyleSheet("qproperty-alignment: AlignCenter;")
        self.hlayout.addWidget(self.headCheckBox[i])
        ### Hide CheckBox
        self.hideCheckBox.append(qt.QCheckBox(self.ECRows[i]))
        self.hideCheckBox[i].setMaximumWidth(hsize[4])
        self.hideCheckBox[i].setMaximumHeight(20)
        self.hideCheckBox[i].setStyleSheet("qproperty-alignment: AlignCenter;")
        self.hlayout.addWidget(self.hideCheckBox[i])
        ##### Fine Riga
        self.configurationCBLayout.addWidget(self.ECRows[i])


###################################################
#### 4. Setup della quarta parte dell'interfaccia
#### In questa parte c'e' l'interfaccia per la segmentazione
###################################################
  def setupSegmentation(self):
    self.segmentationCB = ctk.ctkCollapsibleButton()
    self.segmentationCB.text = "Step 4 : Segmentation"
    self.layout.addWidget(self.segmentationCB)

    # Layout within the dummy collapsible button
    segmentationCBLayout = qt.QFormLayout(self.segmentationCB)

    # input volume selector
    self.volumeCT = slicer.qMRMLNodeComboBox()
    self.volumeCT.nodeTypes = ( ("vtkMRMLScalarVolumeNode"), "" )
    self.volumeCT.addAttribute( "vtkMRMLScalarVolumeNode", "LabelMap", 0 )
    self.volumeCT.selectNodeUponCreation = True
    self.volumeCT.addEnabled = False
    self.volumeCT.removeEnabled = False
    self.volumeCT.noneEnabled = True
    self.volumeCT.showHidden = False
    self.volumeCT.showChildNodeTypes = False
    self.volumeCT.setMRMLScene( slicer.mrmlScene )
    self.volumeCT.setToolTip( "Pick the input to the algorithm." )
    segmentationCBLayout.addRow("Input Volume: ", self.volumeCT) # 

    # Centered
    self.isFiducialCentered = qt.QRadioButton()

    self.segmentationButton = qt.QPushButton("Apply")
    self.segmentationButton.toolTip = "Run the algorithm."
    self.segmentationButton.enabled = True
    segmentationCBLayout.addRow(self.segmentationButton)

    # connections
    self.segmentationButton.connect('clicked(bool)', self.onSegmentationButton)
    

###################################################
#### 5. Setup della quinta parte dell'interfaccia In questa parte c'e'
#### l'interfaccia per la fare detection della zona del cervello
#### associata ad ogni contatto degli elettrodi segmentati
###################################################
  def setupZoneDetection(self):
    self.zonedetectionCB = ctk.ctkCollapsibleButton()
    self.zonedetectionCB.text = "Step 5 : Zone Detection"
    self.layout.addWidget(self.zonedetectionCB)
    zoneDetectionLayout = qt.QFormLayout(self.zonedetectionCB)

    ### Select Atlas
    self.atlasInputSelector = slicer.qMRMLNodeComboBox()
    self.atlasInputSelector.nodeTypes = ( ("vtkMRMLScalarVolumeNode"), "" )
    self.atlasInputSelector.addAttribute( "vtkMRMLScalarVolumeNode", "LabelMap", 0 )
    self.atlasInputSelector.selectNodeUponCreation = True
    self.atlasInputSelector.addEnabled = False
    self.atlasInputSelector.removeEnabled = False
    self.atlasInputSelector.noneEnabled = True
    self.atlasInputSelector.showHidden = False
    self.atlasInputSelector.showChildNodeTypes = False
    self.atlasInputSelector.setMRMLScene( slicer.mrmlScene )
    self.atlasInputSelector.setToolTip( "Pick the volumetric Atlas." )
    zoneDetectionLayout.addRow("Volumetric parcels: ", self.atlasInputSelector)
    
    self.leftPialInputSelector = slicer.qMRMLNodeComboBox()
    self.leftPialInputSelector.nodeTypes = ( ("vtkMRMLModelNode"), "" )
    self.leftPialInputSelector.selectNodeUponCreation = True
    self.leftPialInputSelector.addEnabled = False
    self.leftPialInputSelector.removeEnabled = False
    self.leftPialInputSelector.noneEnabled = True
    self.leftPialInputSelector.showHidden = False
    self.leftPialInputSelector.showChildNodeTypes = False
    self.leftPialInputSelector.setMRMLScene( slicer.mrmlScene )
    self.leftPialInputSelector.setToolTip( "Pick the left pial." )
    zoneDetectionLayout.addRow("Left Pial: ", self.leftPialInputSelector)

    self.leftWhiteInputSelector = slicer.qMRMLNodeComboBox()
    self.leftWhiteInputSelector.nodeTypes = ( ("vtkMRMLModelNode"), "" )
    self.leftWhiteInputSelector.selectNodeUponCreation = True
    self.leftWhiteInputSelector.addEnabled = False
    self.leftWhiteInputSelector.removeEnabled = False
    self.leftWhiteInputSelector.noneEnabled = True
    self.leftWhiteInputSelector.showHidden = False
    self.leftWhiteInputSelector.showChildNodeTypes = False
    self.leftWhiteInputSelector.setMRMLScene( slicer.mrmlScene )
    self.leftWhiteInputSelector.setToolTip( "Pick the left pial." )
    zoneDetectionLayout.addRow("Left White: ", self.leftWhiteInputSelector)

    self.rightPialInputSelector = slicer.qMRMLNodeComboBox()
    self.rightPialInputSelector.nodeTypes = ( ("vtkMRMLModelNode"), "" )
    self.rightPialInputSelector.selectNodeUponCreation = True
    self.rightPialInputSelector.addEnabled = False
    self.rightPialInputSelector.removeEnabled = False
    self.rightPialInputSelector.noneEnabled = True
    self.rightPialInputSelector.showHidden = False
    self.rightPialInputSelector.showChildNodeTypes = False
    self.rightPialInputSelector.setMRMLScene( slicer.mrmlScene )
    self.rightPialInputSelector.setToolTip( "Pick the right pial." )
    zoneDetectionLayout.addRow("Right Pial: ", self.rightPialInputSelector)

    self.rightWhiteInputSelector = slicer.qMRMLNodeComboBox()
    self.rightWhiteInputSelector.nodeTypes = ( ("vtkMRMLModelNode"), "" )
    self.rightWhiteInputSelector.selectNodeUponCreation = True
    self.rightWhiteInputSelector.addEnabled = False
    self.rightWhiteInputSelector.removeEnabled = False
    self.rightWhiteInputSelector.noneEnabled = True
    self.rightWhiteInputSelector.showHidden = False
    self.rightWhiteInputSelector.showChildNodeTypes = False
    self.rightWhiteInputSelector.setMRMLScene( slicer.mrmlScene )
    self.rightWhiteInputSelector.setToolTip( "Pick the right pial." )
    zoneDetectionLayout.addRow("Right White: ", self.rightWhiteInputSelector)

    
    self.dialog = qt.QFileDialog()
    self.dialog.setFileMode(qt.QFileDialog.AnyFile)
    self.dialog.setToolTip( "Pick the input to the algorithm." )

    self.fidsSelectorZone = slicer.qMRMLNodeComboBox()
    self.fidsSelectorZone.nodeTypes = ( ("vtkMRMLMarkupsFiducialNode"), "" )
    self.fidsSelectorZone.selectNodeUponCreation = False
    self.fidsSelectorZone.addEnabled = False
    self.fidsSelectorZone.removeEnabled = False
    self.fidsSelectorZone.noneEnabled = True
    self.fidsSelectorZone.setMRMLScene( slicer.mrmlScene )
    self.fidsSelectorZone.setToolTip("Select a fiducial list")
    zoneDetectionLayout.addRow("Fiducial : ", self.fidsSelectorZone)
    
    # Run Zone Detection button
    self.zoneButton = qt.QPushButton("Apply")
    self.zoneButton.toolTip = "Run the algorithm."
    self.zoneButton.enabled = True


    #### Aggiungo il bottone al layout
    zoneDetectionLayout.addRow(self.zoneButton)


    # connections
    self.zoneButton.connect('clicked(bool)', self.onZoneButton)


###################################################
#### 6. Xtens integration step: provides 
####  1 - connection to xtens-app 
###   2 - population of json-based metadata 
###   3 - sends data to xtens-app via REST
###   4 - check saved data
###################################################
#  def setupXtensIntegration(self):
#    self.xtensCB = ctk.ctkCollapsibleButton()
#    self.xtensCB.text = "Step 6 : XTENS"
#    self.layout.addWidget(self.xtensCB)
#    xtensLayout= qt.QFormLayout(self.xtensCB)
#    self.subjectList = ctk.ctkComboBox()
#    self.implantList = ctk.ctkComboBox()
#
#
#    self.identifier = qt.QLineEdit('admin')
#    self.password = qt.QLineEdit('admin1982')
#    self.password.setEchoMode(qt.QLineEdit.Password)
#    xtensConnect = qt.QPushButton('Connect')
#    
#    connectionLayout = qt.QHBoxLayout()
#    connectionLayout.addWidget(self.identifier)
#    connectionLayout.addWidget(self.password)
#    connectionLayout.addWidget(xtensConnect)
#
#    addSubjectButton = qt.QPushButton("+")
#    addSubjectButton.setFixedWidth(20)
#    addSubjectButton.toolTip = " Add new subject "
#    addSubjectButton.enabled = True 
#
#    loadSubjectButton = qt.QPushButton("Load")
#    loadSubjectButton.setFixedWidth(40)
#    loadSubjectButton.toolTip = "Load Subjects"
#    loadSubjectButton.enabled = True 
#    
#    subjectLayout = qt.QHBoxLayout()
#    subjectLayout.addWidget(self.subjectList)
#    subjectLayout.addWidget(self.implantList)
#    subjectLayout.addWidget(loadSubjectButton)
#    subjectLayout.addWidget(addSubjectButton)
#
#    fidSelectorLayout = qt.QHBoxLayout()
#
#    self.fidsSelectorXtens = slicer.qMRMLNodeComboBox()
#    self.fidsSelectorXtens.nodeTypes = ( ("vtkMRMLMarkupsFiducialNode"), "" )
#    self.fidsSelectorXtens.selectNodeUponCreation = False
#    self.fidsSelectorXtens.addEnabled = False
#    self.fidsSelectorXtens.removeEnabled = False
#    self.fidsSelectorXtens.noneEnabled = True
#    self.fidsSelectorXtens.showHidden = False
#    self.fidsSelectorXtens.showChildNodeTypes = False
#    self.fidsSelectorXtens.setMRMLScene( slicer.mrmlScene )
#    self.fidsSelectorXtens.setToolTip("Select a fiducial list")
#    
#    saveButton = qt.QPushButton("Save")
#    saveButton.setFixedWidth(40)
#    
#    fidSelectorLayout.addWidget(self.fidsSelectorXtens)
#    fidSelectorLayout.addWidget(saveButton)
#
#    xtensLayout.addRow(" DB Connection ",connectionLayout)
#    xtensLayout.addRow(" Subjects ",subjectLayout)
#    xtensLayout.addRow(" Fiducials ",fidSelectorLayout)
#
#    # connections
#    addSubjectButton.connect('clicked(bool)',self.onAddSubjectButtonClick)
#    xtensConnect.connect('clicked(bool)',self.onXtensConnectButtonClick)
#    saveButton.connect('clicked(bool)',self.onSaveButtonClick)
#    loadSubjectButton.connect('clicked(bool)',self.onLoadButtonClick)
#    self.subjectList.connect('activated(QString)',self.onSubjectSelected)
#
#
#    # Add vertical spacer
#    self.layout.addStretch(1)
#
#  def onSubjectSelected(self,string):
#    if string:
#        [familyName,givenName,bDay,id] = string.split(' ')
#        baseUrl = '10.186.10.57:1337'
#
#        # 3 is the datatype index for xtens-app installed in DIBRIS
#        # TODO: find a smarter, less-context dependent way to get the datatype index
#        url = '/data?type=%d&parentSubject=%d' %(3, int(id) )
#        conn = httplib.HTTPConnection(baseUrl)
#        header = {"Authorization":"Bearer "+self.token}
#        conn.request("GET",url,headers=header)
#
#        response = conn.getresponse()
#        if response.status != 200:
#            print response.content
#        
#        implants = json.loads(response.read())
#        print implants
#        for implant in implants:
#            implantInfo = implant['id']
#            self.implantList.addItem(str(implantInfo))
#
#    return True

  def clearElectrodeList(self):
      last = len(self.ECRows) - 1
      while last >= 0 :
            self.ECRows[last].setParent(None)
            self.ECRows[last].deleteLater()
            self.ECRows.remove(self.ECRows[last])
            item = self.configurationCBLayout.takeAt(self.configurationCBLayout.count())
            print(self.configurationCBLayout.count())
            last = len(self.ECRows) - 1
      
  def cleanup(self):
    pass

#  def onXtensConnectButtonClick(self):
#    """ on Add Button Logic """
#    baseUrl = '10.186.10.57:1337'
#
#    dataBlock = dict(identifier=self.identifier.text,password=self.password.text)
#    data = json.dumps(dataBlock,separators=(',',':'))
#    conn = httplib.HTTPConnection(baseUrl)
#    conn.request("POST","/login",data)
#    response = conn.getresponse()
#    print response.status
#
#    if response.status != 200:
#        print response.content
#
#    dataOut = json.loads(response.read())
#    self.token = dataOut['token']
#    conn.close()
#
#    return True
#
#  def onSaveButtonClick(self):
#    """ on Add Button Logic """
#    baseUrl = '10.186.10.57:1337'
#
#    conn = httplib.HTTPConnection(baseUrl)
#    header = {"Authorization":"Bearer "+self.token}
#
#    fids = self.fidsSelectorXtens.currentNode()
#    nFids = fids.GetNumberOfFiducials()
#
#    print self.implantList.currentText
#
##    for i in xrange(nFids):
##        # update progress bar
##        self.progBar.setValue( (float(i)/nFids)*100 )
##        chLabel = fids.GetNthFiducialLabel(i)
##
##        # istantiate the variable which holds the point
##        currContactCentroid = [0,0,0]
##
##        # copy current position from FiducialList
##        fids.GetNthFiducialPosition(i,currContactCentroid)
##
##        # extract patch name and gmpi
##        [anatPatch, gmpi] = fids.GetNthMarkupDescription(i).split(',')
##
##        # create dictionary with channel information
##        channelInfo = dict(Label=chLabel,\
##                PosX=currContactCentroid[0],PosY=currContactCentroid[1],PosZ=currContactCentroid[2],\
##                patchName=anatPatch,gmpi=float(gmpi))
##        channelStruct = dict(parentData=self.implantList.currentIndex,metadata=channelInfo)
##        
##	data = json.dumps(channelInfo,separators=(',',':'))
##
##        conn.request("POST","/data",data,headers=header)
##
##        response = conn.getresponse()
##        if response.status != 200:
##            print response.content
#        
#    return True
#
#  def onAddSubjectButtonClick(self):
#
#    # for this function we need a pop-up window
##    formDialog = 
#    # we create the subject form
#    formLayout = qt.QFormLayout()
#    firstLevelInfoLayout = qt.QHBoxLayout()
#    secondLevelInfoLayout = qt.QHBoxLayout()
#
#    familyName = qt.QLineEdit()
#    firstName = qt.QLineEdit()
#
#    firstLevelInfoLayout.addWidget(familyName)
#    firstLevelInfoLayout.addWidget(firstName)
#    birthDate = qt.QLineEdit()
#    sex = qt.QComboBox()
#    saveButton = qt.QPushButton()
#
#    secondLevelInfoLayout.addWidget(birthDate)
#    secondLevelInfoLayout.addWidget(sex)
#    secondLevelInfoLayout.addWidget(saveButton)
#
#    formLayout.addRow(firstLevelInfoLayout)
#    formLayout.addRow(secondLevelInfoLayout)
#
#    # connection
#    saveButton.connect('clicked(bool)',self.onAddSubjectSaveButtonClick)
#
#    return True
#
#  def onAddSubjectSaveButtonClick(self):
#      return True
#
#
#  def onLoadButtonClick(self):
#    """ on Add Button Logic """
#    baseUrl = '10.186.10.57:1337'
#
#    conn = httplib.HTTPConnection(baseUrl)
#    header = {"Authorization":"Bearer "+self.token}
#    conn.request("GET","/subject",headers=header)
#    response = conn.getresponse()
#    print response.status
#
#    if response.status != 200:
#         print response.content
#
#    dataOut = json.loads(response.read())
#
#    for subject in dataOut:
#		familyName = subject['personalInfo']['surname']
#		firstName = subject['personalInfo']['givenName']
#                birthDate = subject['personalInfo']['birthDate']
#                subjectId = str(subject['personalInfo']['id'])
#		self.subjectList.addItem(string.join((familyName,firstName,birthDate,subjectId),' '))
#
#    conn.close()
#    return True





###########################################################################
#### on DEETO BUTTON
###########################################################################
  def onDeetoButton(self):
    """ on DEETO Button Logic """
    fileName = qt.QFileDialog.getOpenFileName(self.dialog, "Choose surf directory", "~", "")
    self.deetoE.setText(fileName)

    

###########################################################################  
  def onLoadButton(self):
    print("Run the algorithm")
    if self.fidsSelector.currentNode() == None :
      return
    self.clearElectrodeList()
    electrodeList = DEETOLogic().runLoadFiducial(self.fidsSelector.currentNode(),self.progBar)
    for j in xrange(len(electrodeList)):
      print(electrodeList[j])
    self.loadElectrodeConfiguration(electrodeList)

  def onSegmentationButton(self):
    print("Run the Segmentation Algorithm")
    DEETOLogic().runSegmentation(self.volumeCT.currentNode(),\
                               self.fidsSelector.currentNode(),\
                               self.isFiducialCentered,self.deetoE,self.ECRows,self.comboRows,\
                               self.models,self.tailCheckBox,self.headCheckBox,self.hideCheckBox,self.progBar)

  def onZoneButton(self):
    print("Run the Zone Detection Algorithm")
    DEETOLogic().runZoneDetection(self.atlasInputSelector.currentNode(),\
                                self.fidsSelectorZone.currentNode(),\
                                self.leftPialInputSelector.currentNode(),\
                                self.rightPialInputSelector.currentNode(),\
                                self.leftWhiteInputSelector.currentNode(),\
                                self.rightWhiteInputSelector.currentNode(),\
                                self.lutPath,\
                                self.progBar)


    
######################################################################
# DEETOLogic
######################################################################
class DEETOLogic(ScriptedLoadableModuleLogic):

##########################################################
#### RUN LOAD FIDUCIAL
##########################################################
  def runLoadFiducial(self,fiducials,progBar):

    ###  STEP 1: 
    ###  READ The Fiducial file from the model and create the fiducial mask
    ###  
    electrodeList = []

    # Read electrode entry/target from markup fiducial file
    # and put them in a list
    for i in xrange(fiducials.GetNumberOfFiducials()):
      progBar.setValue( float(i)/ fiducials.GetNumberOfFiducials()*100 )
      electrodeList.append(fiducials.GetNthFiducialLabel(i))

    # we should sort the markups now to save time later on


    # replace the _1 on-the-fly and convert to set to get the unique values
    electrodeList = set([ w.replace('_1','') for w in electrodeList ])

    # cast it back to list from set to support indexing later on 
    electrodeList = list(electrodeList)

    return electrodeList


##########################################################
#### RUN ZONE DETECTION
##########################################################
  def findNearestVertex(self,contact, surfaceVertices):
      dist = numpy.sqrt( numpy.sum( (contact - surfaceVertices)**2,axis=1) )
      return (surfaceVertices[ dist.argmin(),:],dist.argmin())

  def computeGmpi(self,contact,pial,white):
      return (numpy.dot( (contact-white) , (pial - white) ) / numpy.linalg.norm((pial - white))**2 )

  def runZoneDetection(self,inputAtlas, fids, leftPial, rightPial, leftWhite, rightWhite,colorLut,progBar):


    nFids = fids.GetNumberOfFiducials()

    atlas = slicer.util.array(inputAtlas.GetName())

    ras2vox_atlas = vtk.vtkMatrix4x4()

    inputAtlas.GetRASToIJKMatrix(ras2vox_atlas)


    FSLUT = {}
    with open(colorLut,'r') as f:
        for line in f:
          if not re.match('^#',line) and len(line)>10:
                lineTok = re.split('\s+',line)
                FSLUT[int(lineTok[0])] = lineTok[1]

    for i in xrange(nFids):

        chLabel = fids.GetNthFiducialLabel(i)
        # is a left or right channel?
        if re.search('^\w\d+',chLabel) is None:
            # left channel
            pial = leftPial.GetPolyData()
            white = leftWhite.GetPolyData()
        else:
            pial = rightPial.GetPolyData()
            white = rightWhite.GetPolyData()
        

        pialVertices = vtk.util.numpy_support.vtk_to_numpy(pial.GetPoints().GetData())
        whiteVertices = vtk.util.numpy_support.vtk_to_numpy(white.GetPoints().GetData())

        # istantiate the variable which holds the point
        currContactCentroid = [0,0,0]

        # copy current position from FiducialList
        fids.GetNthFiducialPosition(i,currContactCentroid)

        # find nearest vertex coordinates
        (pialNearVtx,pialNearVtxIdx) = self.findNearestVertex(currContactCentroid,pialVertices)
        (whiteNearVtx,whiteNearVtxIdx) = self.findNearestVertex(currContactCentroid,whiteVertices)

        print ",".join([str(pialNearVtx),str(whiteNearVtx),str(currContactCentroid)])
        gmpi = self.computeGmpi(currContactCentroid,pialNearVtx,whiteNearVtx)
        
        # append 1 at the end of array before applying transform
        currContactCentroid.append(1)

        # transform from RAS to IJK
        voxIdx = ras2vox_atlas.MultiplyFloatPoint(currContactCentroid)
        voxIdx = numpy.round(numpy.array(voxIdx[:3])).astype(int)

        # this builds a -3:3 linear mask
        mask = numpy.arange(-3,4)

        print atlas.shape
               
        # get Patch Values from loaded Atlas in a 7x7x7 region around
        # contact centroid and extract the frequency for each unique
        # patch Value present in the region
        patchValues = atlas[numpy.ix_(mask+voxIdx[2],\
                                      mask+voxIdx[1],\
                                      mask+voxIdx[0])]

        uniqueValues = numpy.unique(patchValues)
        patchValues = tuple(patchValues.flatten(1))

        itemfreq = [patchValues.count(x) for x in uniqueValues]

        totPercentage = numpy.sum(itemfreq)

        patchNames = [FSLUT[pValues] for pValues in uniqueValues]

        parcels = dict(zip(itemfreq,patchNames))

#        uniqueValues = uniqueValues[numpy.nonzero(uniqueValues)]
#
#        if uniqueValues.size == 0:
#            anatomicalPositionsString = {100,'Ukn'}
#
#        else:

#            patchValues = tuple(patchValues.flatten(1))
#
#            itemfreq = [patchValues.count(x) for x in uniqueValues]
#
#            totPercentage = numpy.sum(itemfreq) 
#
#            patchValue = 

#            # Check the most frequent patch value this will be assigned 
#            # as most probable anatomic region to the given contact
#            patchValue = uniqueValues[itemfreq == numpy.array(itemfreq).max()]
#
#        # This is at least weird, we shouldn't end up on having more than
#        # one element on patchValue
#        if isinstance(patchValue,numpy.ndarray):
#            patchName = FSLUT[patchValue[0]]
#            print str(voxIdx.tolist())+','.join([patchName,str(gmpi)])
#        else:
#            patchName = FSLUT[patchValue]
#            print str(voxIdx.tolist())+','.join([patchName,str(gmpi)])

        anatomicalPositionsString = [','.join([v,str( round( float(k) / totPercentage * 100 ))]) for k,v in parcels.iteritems()]
        print ','.join(anatomicalPositionsString)

        fids.SetNthMarkupDescription(i,','.join(anatomicalPositionsString))
        progBar.setValue( (float(i)/nFids)*100 )




#######################################################################
##### RUN SEGMENTATION  
#######################################################################
  def runDeetoButton(self,line,dialog):
    """
    Run the actual algorithm
    """
    print("do nothing")
    ###[TODO]
    fileName = qt.QFileDialog.getOpenFileName(dialog, "Open Image", "/home/massimo", "")
    line.setText(fileName)

#######################################################################
##### RUN SEGMENTATION  
#######################################################################b
#### [TODO] : is CENTERED????
#### [TODO] : mancano head and tail
  def runSegmentation(self,inputVolume, fids, isCentered, deetoExecutable,\
                      ECRows, comboRows, models,tailCB,headCB,hideCB,progBar):
    """
    Run the deeto segmentation logic as command line tool
    """
    ####  1) CREATE A NEW FIDUCIAL LIST CALLED ...... [TODO]
    mlogic = slicer.modules.markups.logic()   
    
    ### [TODO] Accrocchio, non so come cambiare questi parametri solo
    ### per il nodo corrente, invece che di default
    mlogic.SetDefaultMarkupsDisplayNodeTextScale(1.3)
    mlogic.SetDefaultMarkupsDisplayNodeGlyphScale(1.5)
    mlogic.SetDefaultMarkupsDisplayNodeColor(0.39,0.78,0.78)  # AZZURRO CACCA
    mlogic.SetDefaultMarkupsDisplayNodeSelectedColor(0.39,1.0,0.39)  # VERDONE CACCA
    
    fidNode = slicer.util.getNode(mlogic.AddNewFiducialNode("recon"))

    #### Iterate on the fiducials
    cE = 0 # current Electrode in tailCB

    progBar.setValue(0)
    for i in range(0,(fids.GetNumberOfFiducials()-1),2):
        if (fids.GetNthFiducialSelected(i) == True):
            tFlag = "-t"
            hFlag = "-e"
            if tailCB[cE].isChecked() == True:
                tFlag = "-l"
            if headCB[cE].isChecked() == True:
                hFlag = "-h"
            if hideCB[cE].isChecked() == False:
            #### 2) CHOOSE BEETWEEN TARGET AND ENTRY
                target = [0.0, 0.0, 0.0]
                entry  = [0.0, 0.0, 0.0]
                fids.GetNthFiducialPosition(i, target)
                fids.GetNthFiducialPosition(i+1, entry)
                distance = (pow(target[0],2.0) + pow(target[1],2.0) + pow(target[2],2.0)) -\
                           (pow(entry[0],2.0) + pow(entry[1],2.0) + pow(entry[2],2.0))
                if distance > 0 :
                    tmp = entry
                    entry = target
                    target = tmp
                #### 3) CHOOSE the type of model
                modelType =  comboRows[cE].currentText
                #### 4) PREPARE the command line
                m = [deetoExecutable.text,'-ct',inputVolume.GetNodeReference("storage").GetFileName(),\
                     hFlag, str(-1*entry[0]), str(-1*entry[1]), str(entry[2]), tFlag ,\
                     str(-1*target[0]),str(-1*target[1]),str(target[2]),'-m'] +\
                    map(str,models[modelType])
                #### 5) RUN the command line. [NOTE] : I have used Popen
                ####    since subprocess.check_output wont work at the moment
                print m
                points = []
                points = subprocess.Popen(m,stdout=subprocess.PIPE).communicate()[0].splitlines()
                progBar.setValue( (float(i)/fids.GetNumberOfFiducials()-1)*100)
                #### 6) For each of the point returned by deeto we add it to the new markup fiducial
                name = fids.GetNthFiducialLabel(i) 
                for p in range(0,(len(points) - 1),3):
                    a = fidNode.AddFiducial(float(points[p]),float(points[p+1]),float(points[p+2]))
                    fidNode.SetNthFiducialLabel(a, name + str((p/3) + 1))
                cE = cE + 1  
    # [TODO] Accrocchio, non so come cambiare questi parametri solo
    # per il nodo corrente, invece che di default
    mlogic.SetDefaultMarkupsDisplayNodeTextScale(2.1)
    mlogic.SetDefaultMarkupsDisplayNodeGlyphScale(3.4)
    mlogic.SetDefaultMarkupsDisplayNodeColor(1.0,0.501960784,0.501960784)
    mlogic.SetDefaultMarkupsDisplayNodeSelectedColor(0.4,1.0,1.0)


class DEETOTest(ScriptedLoadableModuleTest):
  """
  This is the test case for your scripted module.
  Uses ScriptedLoadableModuleTest base class, available at:
  https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
  """

  def setUp(self):
    """ Do whatever is needed to reset the state - typically a scene clear will be enough.
    """
    slicer.mrmlScene.Clear(0)

  def runTest(self):
    """Run as few or as many tests as needed here.
    """
    self.setUp()
    self.test_DEETO1()

  def test_DEETO1(self):
    return True
