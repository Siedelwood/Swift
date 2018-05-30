package eu.jlmb.MapIcon;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

/**
 * 
 * @author Jean Baumgarten
 *
 */
public class IconCreater {

	private final BufferedImage image;

	/**
	 * Constructor of IconCreator
	 * @param icon that should be used
	 */
	public IconCreater(BufferedImage icon) {
		this.image = icon;
	}

	/**
	 * Saves the icon to the given location
	 * @param file the icon should be saved in
	 */
	public void save(File file) {
		try {
			ImageIO.write(this.image, "png", file);
		} catch (IOException e) {
			System.err.println("Error while writing image: " + e.getMessage());
		}
	}

	/**
	 * gives back the current state of the image
	 * @return the icons current state
	 */
	public BufferedImage getIcon() {
		return this.image;
	}
	
	/**
	 * adds another image over the current image
	 * @param other is the image to add
	 */
	public void addOverlappImage(BufferedImage other) {
		Boolean hasAlpha = other.getColorModel().hasAlpha();
		for (int x = 0; x < this.image.getWidth(); x++) {
			for (int y = 0; y < this.image.getHeight(); y++) {
				Color color = new Color(other.getRGB(x, y), hasAlpha);
				Color imagecolor = new Color(this.image.getRGB(x, y), hasAlpha);
				if (color.getAlpha() == 255) {
					//this.image.setRGB(x, y, color.getRGB());
					this.image.setRGB(x, y, getCombiningColor(imagecolor, color).getRGB());
				}
			}
		}
	}
	
	/**
	 * generates a color out of the two given ones
	 * @param back color of the background
	 * @param front color of the foreground
	 * @return a new color
	 */
	private static Color getCombiningColor(Color back, Color front) {
		int fa = front.getAlpha();
		if (fa == 255) {
			return front;
		} else {
			int nr = front.getRed() + back.getRed();
			int ng = front.getGreen() + back.getGreen();
			int nb = front.getBlue() + back.getBlue();
			int na = fa + back.getAlpha();
			return new Color(nr / 2, ng / 2, nb / 2, na / 2);
			//return new Color(nr > 255 ? 255 : nr, ng > 255 ? 255 : ng, nb > 255 ? 255 : nb, na > 255 ? 255 : na);
		}
	}
	
	/**
	 * adds another image over the current image and cuts of borders
	 * @param other is the image to add
	 */
	public void addCutOutImage(BufferedImage other) {
		Boolean hasAlpha = other.getColorModel().hasAlpha();
		Color transparent = new Color(0, 0, 0, 0);
		for (int x = 0; x < this.image.getWidth(); x++) {
			for (int y = 0; y < this.image.getHeight(); y++) {
				Color color = new Color(other.getRGB(x, y), hasAlpha);
				Color imagecolor = new Color(this.image.getRGB(x, y), hasAlpha);
				if (!isInsideBigMapCircle(x, y)) {
					this.image.setRGB(x, y, transparent.getRGB());
				}
				if (color.getAlpha() != 0) {
					if (isInsideBigMapCircle(x, y)) {
						this.image.setRGB(x, y, getCombiningColor(imagecolor, color).getRGB());
					} else {
						this.image.setRGB(x, y, color.getRGB());
					}
				}
			}
		}
	}
	
	/**
	 * checks if a point is inside a small circle around the center of the map
	 * @param x is the x position of the point
	 * @param y is the y position of the point
	 * @return true if the point is inside that small circle
	 */
	private static Boolean isInsideSmallMapCircle(int x, int y) {
		return isInsideMapCircleOfRadius(62, x, y);
	}

	/**
	 * checks if a point is inside a big circle around the center of the map
	 * @param x is the x position of the point
	 * @param y is the y position of the point
	 * @return true if the point is inside that big circle
	 */
	private static Boolean isInsideBigMapCircle(int x, int y) {
		return isInsideMapCircleOfRadius(65, x, y);
	}
	
	/**
	 * checks if a point is inside a circle of given radius around the center of the map
	 * @param radius of the circle to check
	 * @param x is the x position of the point
	 * @param y is the y position of the point
	 * @return true if the point is inside that circle
	 */
	private static Boolean isInsideMapCircleOfRadius(int radius, int x, int y) {
		return ((x - 97) * (x - 97) + (y - 90) * (y - 90)) < (radius * radius);
	}
	
	/**
	 * cuts off every part of the icon that is not landscape
	 */
	public void cutOutLandscape() {
		Color transparent = new Color(0, 0, 0, 0);
		for (int x = 0; x < this.image.getWidth(); x++) {
			for (int y = 0; y < this.image.getHeight(); y++) {
				if (!isInsideSmallMapCircle(x, y)) {
					this.image.setRGB(x, y, transparent.getRGB());
				}
			}
		}
	}
	
	/**
	 * creates a picture that has the right size to be uploaded
	 * @param picture input picture
	 * @return output picture
	 */
	public static BufferedImage makeOutputImage(BufferedImage picture) {
		return resizeToIcon(makeSquare(cutAlphaBorder(picture)));
	}
	
	/**
	 * creates a new image without the transparent border of this image
	 * @param picture to be treated
	 * @return an image without transparent borders
	 */
	private static BufferedImage cutAlphaBorder(BufferedImage picture) {
		int width = picture.getWidth();
		int height = picture.getHeight();
		int startX = width;
		int startY = height;
		int endX = 0;
		int endY = 0;
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				Color color = new Color(picture.getRGB(x, y), true);
				if (color.getAlpha() != 0) {
					startX = Math.min(x, startX);
					startY = Math.min(y, startY);
					endX = Math.max(x, endX);
					endY = Math.max(y, endY);
				}
			}
		}
		startX = (startX > 2) ? (startX - 2) : startX;
		startY = (startY > 2) ? (startY - 2) : startY;
		endX = (endX < (width - 2)) ? (endX + 2) : endX;
		endY = (endY < (height - 2)) ? (endY + 2) : endY;
		int dx = endX - startX;
		int dy = endY - startY;
		BufferedImage cutImage = new BufferedImage(dx, dy, BufferedImage.TYPE_INT_ARGB);
		for (int x = 0; x < dx; x++) {
			for (int y = 0; y < dy; y++) {
				Color color = new Color(picture.getRGB(x + startX, y + startY), true);
				cutImage.setRGB(x, y, color.getRGB());
			}
		}
		return cutImage;
	}
	
	/**
	 * creates an image with a square shape out of the given image
	 * @param picture to be treated
	 * @return a square image
	 */
	private static BufferedImage makeSquare(BufferedImage picture) {
		int sideLengh = Math.max(picture.getWidth(), picture.getHeight());
		BufferedImage squaredImage = new BufferedImage(sideLengh, sideLengh, BufferedImage.TYPE_INT_ARGB);
		int startX = (sideLengh - picture.getWidth()) / 2;
		int startY = (sideLengh - picture.getHeight()) / 2;
		for (int x = 0; x < picture.getWidth(); x++) {
			for (int y = 0; y < picture.getHeight(); y++) {
				Color color = new Color(picture.getRGB(x, y), true);
				squaredImage.setRGB(x + startX, y + startY, color.getRGB());
			}
		}
		return squaredImage;
		
	}

	/**
	 * resizes an image to 100x100
	 * @param picture to resize
	 * @return a resized BufferedImage
	 */
	private static BufferedImage resizeToIcon(BufferedImage picture) {
		int side = 100;
		if (side != picture.getWidth() && side != picture.getHeight()) {
			Image scaledImage = picture.getScaledInstance(side, side, Image.SCALE_SMOOTH);
			BufferedImage resizedImage = new BufferedImage(side, side, BufferedImage.TYPE_INT_ARGB);
			Graphics2D graphic = resizedImage.createGraphics();
			graphic.drawImage(scaledImage, 0, 0, null);
			graphic.dispose();
			return resizedImage;
		} else {
			return picture;
		}
	}

}