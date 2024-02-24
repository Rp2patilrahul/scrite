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

#ifndef FOUNTAINEXPORTER_H
#define FOUNTAINEXPORTER_H

#include "abstractexporter.h"

class FountainExporter : public AbstractExporter
{
    Q_OBJECT
    Q_CLASSINFO("Format", "Screenplay/Fountain")
    Q_CLASSINFO("NameFilters", "Fountain (*.fountain)")
    Q_CLASSINFO("Description", "Exports the current screenplay to Fountain file format.")
    Q_CLASSINFO("Icon", ":/icons/exporter/fountain.png")

public:
    Q_INVOKABLE explicit FountainExporter(QObject *parent = nullptr);
    ~FountainExporter();

    bool canBundleFonts() const { return false; }
    bool requiresConfiguration() const { return false; }

protected:
    bool doExport(QIODevice *device); // AbstractExporter interface
    QString fileNameExtension() const { return QStringLiteral("fountain"); }
};

#endif // FOUNTAINEXPORTER_H
