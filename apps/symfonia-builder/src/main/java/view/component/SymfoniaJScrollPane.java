package view.component;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.border.LineBorder;

import view.window.DefaultWindow;
import view.window.WindowInterface;

/**
 * 
 * 
 * @author angermanager
 *
 */
public class SymfoniaJScrollPane extends JPanel implements ActionListener
{
    /**
     * 
     */
    private final JScrollPane scroll;
    
    /**
     * 
     */
    private final WindowInterface parent;
    
    /**
     * 
     * @param x
     * @param y
     * @param parent
     */
    public SymfoniaJScrollPane(final int x, final int y, final int w, final int h, final WindowInterface parent)
    {
        super();
        this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        this.parent = parent;
        
        setSize(w, h);
        
        scroll = new JScrollPane(this);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        scroll.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
        scroll.setPreferredSize(new Dimension(w, h));
        scroll.setBackground(new Color(0,0,0,0));
        scroll.setBorder(null);
        final Dimension size = scroll.getPreferredSize();
        scroll.setBounds(x, y, size.width, size.height);
        scroll.setOpaque(true);
        
        setBackground(new Color(0,0,0,0));
        setSize(w, h);
        parent.getRootPane().add(scroll);
        
        for (int i = 0; i < 15; i++) {
            final JPanel b = new JPanel(null);
            b.setPreferredSize(new Dimension(size.width-20, 50));
            b.setMaximumSize(new Dimension(size.width-20, 50));
            b.setMinimumSize(new Dimension(size.width-20, 50));
            b.setBackground(Color.WHITE);
            b.setBorder(new LineBorder(Color.BLACK));
            add(b);
        }
    }

    /**
     * 
     */
    @Override
    public void actionPerformed(final ActionEvent e)
    {
        
    }
    
    /**
     * 
     * @param args
     */
    public static void main(final String[] args)
    {
        final int x = 800;
        final int y = 500;
        
        final JFrame frame = new JFrame();
        frame.setBounds(0, 0, x, y);
        
        final DefaultWindow window = new DefaultWindow(x, y);
        
        final SymfoniaJScrollPane scroll = new SymfoniaJScrollPane(30, 30, x-60, y-150, window);
        
        frame.add(window.getRootPane());
        frame.setVisible(true);
    }
}
