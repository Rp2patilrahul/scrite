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

#ifndef NOTEBOOKREPORT_H
#define NOTEBOOKREPORT_H

#include "abstractreportgenerator.h"

#include <QJsonValue>

class NotebookReport : public AbstractReportGenerator
{
    Q_OBJECT
    Q_CLASSINFO("Title", "Notebook Report")
    Q_CLASSINFO("Description", "Generates a report of notes in the Notebook.")
    Q_CLASSINFO("Icon", ":/icons/reports/notebook_report.png")

public:
    Q_INVOKABLE NotebookReport(QObject *parent = nullptr);
    ~NotebookReport();

    Q_CLASSINFO("actsOnNewPage_FieldGroup", "Basic")
    Q_CLASSINFO("actsOnNewPage_FieldLabel", "Start each Act on a new page.")
    Q_CLASSINFO("actsOnNewPage_FieldEditor", "CheckBox")
    Q_PROPERTY(bool actsOnNewPage READ isActsOnNewPage WRITE setActsOnNewPage NOTIFY actsOnNewPageChanged)
    void setActsOnNewPage(bool val);
    bool isActsOnNewPage() const { return m_actsOnNewPage; }
    Q_SIGNAL void actsOnNewPageChanged();

    Q_CLASSINFO("episodesOnNewPage_FieldGroup", "Basic")
    Q_CLASSINFO("episodesOnNewPage_FieldLabel", "Start each Episode on a new page.")
    Q_CLASSINFO("episodesOnNewPage_FieldEditor", "CheckBox")
    Q_PROPERTY(bool episodesOnNewPage READ isEpisodesOnNewPage WRITE setEpisodesOnNewPage NOTIFY episodesOnNewPageChanged)
    void setEpisodesOnNewPage(bool val);
    bool isEpisodesOnNewPage() const { return m_episodesOnNewPage; }
    Q_SIGNAL void episodesOnNewPageChanged();

    // Can be Scene, Structure, Screenplay, Character, Notes or Note
    // Otherwise it generates a dump of all notes in the Notebook
    Q_PROPERTY(QObject *section READ section WRITE setSection NOTIFY sectionChanged STORED false)
    void setSection(QObject *val);
    QObject *section() const { return m_section; }
    Q_SIGNAL void sectionChanged();

    Q_PROPERTY(QJsonValue options READ options WRITE setOptions NOTIFY optionsChanged STORED false)
    void setOptions(const QJsonValue &val);
    QJsonValue options() const { return m_options; }
    Q_SIGNAL void optionsChanged();

protected:
    // AbstractDeviceIO interface
    QString polishFileName(const QString &fileName) const;

public:
    // AbstractReportGenerator interface
    bool requiresConfiguration() const { return false; }
    void polishFormInfo(QJsonObject &) const;

protected:
    bool doGenerate(QTextDocument *);

private:
    void evaluateTitleAndSubtitle();

private:
    Note *m_noteSection = nullptr;
    Notes *m_notesSection = nullptr;
    Scene *m_sceneSection = nullptr;
    Structure *m_storySection = nullptr;
    Character *m_characterSection = nullptr;
    Screenplay *m_screenplaySection = nullptr;

    QObject *m_section = nullptr;
    QJsonValue m_options;

    QString m_title;
    QString m_subtitle;
    bool m_actsOnNewPage = false;
    bool m_episodesOnNewPage = false;
};

#endif // NOTEBOOKREPORT_H
