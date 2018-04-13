package view.window;

import java.awt.event.ActionEvent;

import javax.swing.event.ListSelectionEvent;

import view.component.SymfoniaJPanel;

/**
 * 
 * @author angermanager
 *
 */
public abstract class AbstractWindow implements WindowInterface {

    /**
     * 
     */
    protected SymfoniaJPanel root;

    /**
     * 
     */
    public AbstractWindow(final int w, final int h) {
        root = new SymfoniaJPanel(null);
        root.setBounds(0, 0, w, h);
        root.setVisible(true);
    }

    /**
     * 
     */
    @Override
    public void show() {
        root.setVisible(true);
    }

    /**
     * 
     */
    @Override
    public void hide() {
        root.setVisible(false);
    }

    /**
     * 
     * @return
     */
    @Override
    public SymfoniaJPanel getRootPane() {
        return root;
    }

    /**
     * {@inheritDoc}
     * 
     * @throws WindowException
     */
    @Override
    public abstract void handleActionEvent(final ActionEvent aE) throws WindowException;

    /**
     * {@inheritDoc}
     */
    @Override
    public abstract void handleValueChanged(final ListSelectionEvent a);

    /**
     * {@inheritDoc}
     */
    @Override
    public void valueChanged(final ListSelectionEvent aE) {
        handleValueChanged(aE);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void actionPerformed(final ActionEvent aE) {
        try {
            handleActionEvent(aE);
        } catch (final WindowException e) {
            e.printStackTrace();
        }
    }
}
