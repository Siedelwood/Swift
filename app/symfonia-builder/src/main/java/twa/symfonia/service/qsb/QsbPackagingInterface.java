package twa.symfonia.service.qsb;

import twa.symfonia.model.LoadOrderModel;

/**
 * Packt die QSB inklusive der Zusatzoptionen in den angegebenen Pfad
 * 
 * @author totalwarANGEL
 *
 */
public interface QsbPackagingInterface
{

    /**
     * 
     * @param loadOrder
     * @param dest
     * @param copyDoc
     * @param copyBaseScripts
     * @param copyExamples
     * @param minifyQsb
     * @throws QsbPackagingException
     */
    public void pack(
        final LoadOrderModel loadOrder,
        final String dest,
        final boolean copyDoc,
        final boolean copyBaseScripts,
        final boolean copyExamples,
        final boolean minifyQsb
    ) throws QsbPackagingException;

    /**
     * 
     * @param path
     * @throws QsbPackagingException
     */
    public void saveBasicScripts(final String path) throws QsbPackagingException;

    /**
     * 
     * @param dest
     * @throws QsbPackagingException
     */
    public void saveDocumentation(final String dest) throws QsbPackagingException;

    /**
     * 
     * @param path
     * @throws QsbPackagingException
     */
    void saveExamples(String path) throws QsbPackagingException;
}
