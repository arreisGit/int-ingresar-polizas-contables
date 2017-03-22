Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.ComponentModel
Imports System.Data.SqlTypes
Imports System.Xml.Serialization
Imports System.IO
Imports System.Xml

<System.Web.Script.Services.ScriptService()> _
<System.Web.Services.WebService( _
  Namespace:="http://wwww.cml-planos.com/JournalEntry", _
  Description:="Service responsible for controlling the dispatch of journal entries to INTELISIS")> _
<System.Web.Services.WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<ToolboxItem(False)> _
Public Class PolizasIntelisis
  Inherits System.Web.Services.WebService

  <WebMethod(Description:="Sends a journal entry to INTELISIS")>
  Public Function Send(JournalEntry As JournalEntry) As List(Of Message)

    Dim messages As New List(Of Message)

    Try

      Dim XML As String = ObjectToXMLGeneric(JournalEntry)

      clsSQL.AddParameter("@Poliza", XML)
      messages = clsSQL.List("CUP_SPI_PolizasContables", CommandType.StoredProcedure, "connectionString").toList(Of Message)()

    Catch ex As Exception
      messages.Add(New Message(1, ex.Message.ToString()))
    End Try

    Return messages
  End Function

  'Returns an Object in XML formatt
  Private Function ObjectToXMLGeneric(Of T)(filter As T) As String

    Dim settings As New XmlWriterSettings()
    settings.Encoding = New UnicodeEncoding(False, False)
    settings.Indent = True
    settings.OmitXmlDeclaration = True

    Dim XML As String = Nothing

    Using writer As New StringWriter()
      Dim serializer As New XmlSerializer(GetType(T))

      Using xmlWriter As XmlWriter = xmlWriter.Create(writer, settings)
        serializer.Serialize(xmlWriter, filter)
      End Using

      Try
        XML = writer.ToString()
      Catch e As Exception
        Throw e
      End Try

    End Using

    Return XML
  End Function


End Class

' Representa la respuesta del Web Service
Public Class Message

  ' Descripcion general del mensaje
  Public Property Num As Integer
  Public Property Description As String

  ' Valores de la poliza creada
  Public Property ID As String
  Public Function ShouldSerializeID() As Boolean
    Return Not String.IsNullOrWhiteSpace(MovID)
  End Function

  Public Property Mov As String
  Public Function ShouldSerializeMov() As Boolean
    Return Not String.IsNullOrWhiteSpace(Mov)
  End Function

  Public Property MovID As String
  Public Function ShouldSerializeMovID() As Boolean
    Return Not String.IsNullOrWhiteSpace(MovID)
  End Function

  Public Sub New()
    Num = 0
    Description = Nothing
    ID = Nothing
    Mov = Nothing
    MovID = Nothing
  End Sub

  Public Sub New(ByVal n As Integer, ByVal m As String)
    Num = n
    Description = m
    ID = Nothing
    Mov = Nothing
    MovID = Nothing
  End Sub
End Class

' Representa las partidas de la poliza.
Public Class Record
  Public Property Account As String
  Public Property CostCenter As String
  Public Property Debit As Double
  Public Property Credit As Double
  Public Property Concept As String
  Public Property OriginalCurrency As String
  Public Property OriginalExchangeRate As String
End Class

' Representa la póliza contable.
<XmlRoot("JournalEntry")>
Public Class JournalEntry

  <XmlAttribute("System")>
  Public Property System As Integer

  Public Property Type As String
  Public Function ShouldSerializeType() As Boolean
    Return Not String.IsNullOrWhiteSpace(Type)
  End Function

  <XmlElement("EffectiveDate", DataType:="date")>
  Public Property EffectiveDate As Nullable(Of Date)

  Public Property Branch As Nullable(Of Integer)
  Public Function ShouldSerializeBranch() As Boolean
    Return Branch.HasValue
  End Function

  Public Property Concept As String
  Public Property Reference As String
  Public Property Records As List(Of Record)
End Class