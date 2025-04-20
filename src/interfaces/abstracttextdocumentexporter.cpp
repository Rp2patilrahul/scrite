/****************************************************************************
**
** Copyright (C) VCreate Logic Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth@scrite.io)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#include "abstracttextdocumentexporter.h"
#include "screenplaytextdocument.h"

AbstractTextDocumentExporter::AbstractTextDocumentExporter(QObject *parent)
    : AbstractExporter(parent)
{
}

AbstractTextDocumentExporter::~AbstractTextDocumentExporter() { }

void AbstractTextDocumentExporter::setListSceneCharacters(bool val)
{
    if (m_listSceneCharacters == val)
        return;

    m_listSceneCharacters = val;
    emit listSceneCharactersChanged();
}

void AbstractTextDocumentExporter::setIncludeSceneSynopsis(bool val)
{
    if (m_includeSceneSynopsis == val)
        return;

    m_includeSceneSynopsis = val;
    emit includeSceneSynopsisChanged();
}

void AbstractTextDocumentExporter::setIncludeSceneFeaturedImage(bool val)
{
    if (m_includeSceneFeaturedImage == val)
        return;

    m_includeSceneFeaturedImage = val;
    emit includeSceneFeaturedImageChanged();
}

void AbstractTextDocumentExporter::setUseSceneColors(bool val)
{
    if (m_useSceneColors == val)
        return;

    m_useSceneColors = val;
    emit useSceneColorsChanged();
}

void AbstractTextDocumentExporter::setIncludeSceneComments(bool val)
{
    if (m_includeSceneComments == val)
        return;

    m_includeSceneComments = val;
    emit includeSceneCommentsChanged();
}

void AbstractTextDocumentExporter::setIncludeSceneContents(bool val)
{
    if (m_includeSceneContents == val)
        return;

    m_includeSceneContents = val;
    emit includeSceneContentsChanged();
}

void AbstractTextDocumentExporter::setCapitalizeSentences(bool val)
{
    if (m_capitalizeSentences == val)
        return;

    m_capitalizeSentences = val;
    emit capitalizeSentencesChanged();
}

void AbstractTextDocumentExporter::setPolishParagraphs(bool val)
{
    if (m_polishParagraphs == val)
        return;

    m_polishParagraphs = val;
    emit polishParagraphsChanged();
}

void AbstractTextDocumentExporter::generate(QTextDocument *textDoc, const qreal pageWidth)
{
    Q_UNUSED(pageWidth)

    Screenplay *screenplay = this->document()->screenplay();
    if (m_capitalizeSentences)
        screenplay->capitalizeSentences();
    if (m_polishParagraphs)
        screenplay->polishText();

    ScreenplayTextDocument stDoc;
    stDoc.setTitlePage(this->generateTitlePage());
    stDoc.setIncludeLoglineInTitlePage(this->isIncludeLogline());
    stDoc.setSceneNumbers(this->isIncludeSceneNumbers());
    stDoc.setSceneIcons(this->isIncludeSceneIcons());
    stDoc.setSceneColors(this->isUseSceneColors());
    stDoc.setListSceneCharacters(m_listSceneCharacters);
    stDoc.setIncludeSceneSynopsis(m_includeSceneSynopsis);
    stDoc.setIncludeSceneFeaturedImage(m_includeSceneFeaturedImage);
    stDoc.setIncludeSceneComments(m_includeSceneComments);
    stDoc.setPrintEachSceneOnANewPage(this->isPrintEachSceneOnANewPage());
    stDoc.setPrintEachActOnANewPage(this->isPrintEachActOnANewPage());
    stDoc.setIncludeActBreaks(this->isIncludeActBreaks());
    stDoc.setSyncEnabled(false);
    if (this->isExportForPrintingPurpose() || (this->usePageBreaks() && m_includeSceneContents)) {
        stDoc.setPurpose(ScreenplayTextDocument::ForPrinting);
        stDoc.setIncludeMoreAndContdMarkers(this->usePageBreaks());
    } else
        stDoc.setPurpose(ScreenplayTextDocument::ForDisplay);
    stDoc.setScreenplay(this->document()->screenplay());
    stDoc.setFormatting(this->document()->printFormat());
    stDoc.setTitlePageIsCentered(this->document()->screenplay()->isTitlePageIsCentered());
    stDoc.setTextDocument(textDoc);
    stDoc.setInjection(this);
    stDoc.syncNow(this->progress());
}

bool AbstractTextDocumentExporter::filterSceneElement() const
{
    return !m_includeSceneContents;
}
