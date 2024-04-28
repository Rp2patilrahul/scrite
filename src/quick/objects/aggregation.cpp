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

#include "aggregation.h"
#include "application.h"

Aggregation::Aggregation(QObject *parent) : QObject(parent) { }

Aggregation::~Aggregation() { }

Aggregation *Aggregation::qmlAttachedProperties(QObject *object)
{
    return new Aggregation(object);
}

QObject *Aggregation::find(QObject *object, const QString &className, const QString &objectName)
{
    if (object == nullptr)
        return nullptr;

    const QObjectList children = object->children();
    for (QObject *child : children) {
        if (child->inherits(qPrintable(className))) {
            if (objectName.isEmpty())
                return child;

            if (child->objectName() == objectName)
                return child;
        }
    }

    return nullptr;
}

ErrorReport *Aggregation::findErrorReport(QObject *object)
{
    return object->findChild<ErrorReport *>(QString(), Qt::FindDirectChildrenOnly);
}

ProgressReport *Aggregation::findProgressReport(QObject *object)
{
    return object->findChild<ProgressReport *>(QString(), Qt::FindDirectChildrenOnly);
}

QObject *Aggregation::firstChild(const QString &className)
{
    return Application::findFirstChildOfType(this->parent(), className);
}

QObject *Aggregation::firstParent(const QString &className)
{
    return Application::findFirstParentOfType(this->parent(), className);
}

QObject *Aggregation::firstSibling(const QString &className)
{
    return Application::findFirstSiblingOfType(this->parent(), className);
}
